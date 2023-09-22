# Ifrah Malik
# Project Name: Assignment 1 
# Filename: PitchInFun
# Description: Project matches students with volunteer events that match their interests
# Last modified: 09/21/2023

require 'csv'

#initialze event hashmap
event = {}
student = {}

valid_issues = ['food insecurity', 'poverty', 'racial inequality', 'climate change', 'homelessness', 'healthcare', 'gender inequality']

# read in from input file 1 and store in 'event' hash
CSV.foreach('events2.csv', headers: true) do |row|
  event[row['Event-Id']] = {
    'Event-Name' => row['Event-Name'],
    'Event-Issues' => row['Event-Issues'].split('; '),
    'Min-Students' => row['Min-Students'].to_i,
    'Max-Students' => row['Max-Students'].to_i,
    'Assigned-Students' => 0
  }
end

# array of studentIds that did not enter correct amount of interests (like 0, 1, or more than 5) or entered an invalid social-issue 
invalid_interests = []

number_valid_students = 0 
# read in from input file 2 and store in 'student' hash
CSV.foreach('student2.csv', headers: true) do |row|
  student_id = row['Student-Id']
  interests = row['Interests'].to_s.split('; ').map(&:strip)
  
  if interests.length >= 2 && interests.length <= 4 && !(interests & valid_issues).empty?
    student[student_id]= {
      'Interests' => interests
    }
    number_valid_students = number_valid_students + 1
  else
    invalid_interests << student_id
  end
end

# Sort students by the number of least to most interests to optimize matching students with low amount of interests
sorted_students = student.sort_by { |_, data| data['Interests'].length }
# make the sorted students array of arrays into a hash
sorted_students_hash = Hash[sorted_students]

# hash to store the matched event for each student
matching_events = {}
# # array to store matching event ID for a student
# matching_event_ids = []

# Iterate through each student
sorted_students_hash.each do |student_id, student_data|
  student_interests = student_data['Interests']
  matching_event_ids = []
  # Iterate through each event from valid events hash
  event.each do |event_id, event_data|
    event_issues = event_data['Event-Issues']
    event_name = event_data['Event-Name']
    min_students = event_data['Min-Students']
    max_students = event_data['Max-Students']
    assigned_students = event_data['Assigned-Students']

    roster = [student_id]
    # Check if there's a match between event_issues and student_interests
    if (event_issues & student_interests).any?
      # Check if the event has available capacity
      if (max_students > assigned_students && min_students != assigned_students)
        matching_event_ids << event_id
        # Check if roster element exists in hash
        if event_data.key?('Roster')
          # If it exists, append roster_data to the existing list
          event_data['Roster'] << roster
          event[event_id]['Assigned-Students'] += 1
        else
          # If it doesn't exist, initialize it as an array containing roster_data
          event_data['Roster'] = roster
          event[event_id]['Assigned-Students'] += 1
        end
        # break out of event loop so to only match one event with a student
        break 
      end
    end
  end
  # Store the matching event ID for student
  matching_events[student_id] = matching_event_ids
end


# handle invalid student interests 
invalid_interests.each do |student_id|
  matching_event_ids = []
  # Sort the events hash by the difference between Min-Students and Assigned-Students
  sorted_events = event.sort_by do |event_id, event_data|
    min_students = event_data['Min-Students']
    assigned_students = event_data['Assigned-Students']
    (assigned_students - min_students).abs
  end.to_h

  roster = [student_id]

  # place invalid student into event that needs it 
  sorted_events.each do |event_id, event_data|
    assigned_students = event_data['Assigned-Students']
    min_students = event_data['Min-Students']
    max_students = event_data['Max-Students']

    if (assigned_students >= min_students && assigned_students < max_students)
      matching_event_ids << event_id
      matching_events[student_id] = matching_event_ids
      # Check if event_data['Roster'] already exists
      if event_data.key?('Roster')
        # If it exists, append roster_data to the existing list
        event_data['Roster'] << roster
        event[event_id]['Assigned-Students'] += 1
      else
        # If it doesn't exist, initialize it as an array containing roster_data
        event_data['Roster'] = roster
        event[event_id]['Assigned-Students'] += 1
      end
      break
    end
  end
end

# to populate the roster element in the events hash with 'none' for the events with no students
event.each do |event_id, event_data|
  roster_data = ["none"]
  if !event_data.key?('Roster')
    event_data['Roster'] = roster_data
  end
end

# to handle remaing students who were not placed in events
unmatched_students_arr = []
unmatched_students = 0
matching_events.each do |student_id, event_id|
  if event_id.empty?
    unmatched_students = unmatched_students + 1
    unmatched_students_arr << student_id
  end
end
puts unmatched_students_arr.length

# puts remaining students into open events
unmatched_students_arr.each do |student_id, student_data|
  event.each do |event_id, event_data|
    assigned_students = event_data['Assigned-Students']
    min_students = event_data['Min-Students']
    max_students = event_data['Max-Students']
    event_issues = event_data["Event-Issues"]

    if (assigned_students >= min_students && assigned_students < max_students)
      matching_events[student_id] = event_id
      unmatched_students = unmatched_students - 1
      # Check if event_data['Roster'] already exists
      if event_data.key?('Roster')
        # If it exists, append roster_data to the existing list
        event_data['Roster'] << [student_id]
        event[event_id]['Assigned-Students'] += 1
      else
        # If it doesn't exist, initialize it as an array containing roster_data
        event_data['Roster'] = roster
        event[event_id]['Assigned-Students'] += 1
      end
      break
    end
  end
end


# to store all student issues and compare with event to find 'Problem' events
all_student_issues = []
sorted_students_hash.each do |student_id, student_data|
  student_interests = student_data['Interests']
  all_student_issues.concat(student_interests)
end

#  gets user input 
print "enter name of output file 1: "
outputfile1 = gets.chomp

print "enter name of output file 2: "
outputfile2 = gets.chomp

# ----------------------------------to print to output files & screen -------------------------------------
# Open the CSV file in write mode
CSV.open(outputfile1, 'w') do |csv|
  # Write the header row
  csv << ['Event-Id', 'Event-Name', 'Event-Issues', 'Min-Students', 'Max-Students', 'Num-Students', 'Roster', 'Status']

  # Iterate through the events and write each event's data to the CSV file
  event.each do |event_id, event_data|
    event_issues = event_data['Event-Issues']
    num_students = event_data['Assigned-Students']
    roster = event_data['Roster']

    # Determine the 'Status' based on the number of students
    status =  if num_students >= event_data['Min-Students']
                'Ok'
              else
                'Cancel'
              end
    # Check for 'Problem' status based on event issues not listed by any students
    if status == 'Ok'
      if !(event_issues & all_student_issues).any?
        status = 'Problem'
      end
    end

    # Write the event data to the CSV file
    csv << [event_id, event_data['Event-Name'], event_issues.join('; '), event_data['Min-Students'], event_data['Max-Students'], num_students, roster.flatten.join(', '), status]
  end
end

# Calculate the statistics
number_of_events_can_run = event.values.count { |event_data| event_data['Assigned-Students'] >= event_data['Min-Students'] }
number_of_events_may_be_canceled = event.values.count { |event_data| event_data['Assigned-Students'] < event_data['Min-Students'] }
number_of_events_with_zero_students = event.values.count { |event_data| event_data['Assigned-Students'] == 0 } 

# Write the statistics to a text file
File.open(outputfile2, 'w') do |file|
  file.puts "Number of valid students: #{number_valid_students}"
  file.puts "Number of events that can run: #{number_of_events_can_run}"
  file.puts "Number of events that may be canceled: #{number_of_events_may_be_canceled}"
  file.puts "Number of events that have 0 students assigned: #{number_of_events_with_zero_students}"
end

# to print to screen
puts "Event-Id, Event-Name, Event-Issues, Min-Students, Max-Students, Num-Students, Roster, Status"
event.each do |event_id, event_data|
  event_issues = event_data['Event-Issues']
  num_students = event_data['Assigned-Students']
  roster = event_data['Roster']

  # Determine the 'Status' based on the number of students
  status =  if num_students >= event_data['Min-Students']
    'Ok'
  else
    'Cancel'
  end

  # Check for 'Problem' status based on event issues not listed by any students
  if status == 'Ok'
    if !(event_issues & all_student_issues).any?
      status = 'Problem'
    end
  end
  puts "#{event_id}, #{event_data['Event-Name']}, #{event_issues.join('; ')}, #{event_data['Min-Students']}, #{event_data['Max-Students']}, #{num_students}, #{roster.flatten.join(', ')}, #{status}"

end

# print summary (outputfile2) to screen
puts "Number of valid students: #{number_valid_students}"
puts "Number of events that can run: #{number_of_events_can_run}"
puts "Number of events that may be canceled: #{number_of_events_may_be_canceled}"
puts "Number of events that have 0 students assigned: #{number_of_events_with_zero_students}"

puts "**number of students not in an event: #{unmatched_students}"
