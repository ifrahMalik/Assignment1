=begin
Ifrah Malik
CSC415-01 Software Engineering
Dr. Pulimood
Assignment 1
=end

require 'csv'

#initialzing event hashmaps
event = {}

CSV.foreach("/home/student1/vm-csc415/assignment1/events.csv", headers: true) do |row|
  event_id = row['Event-ID']
  event_name = row['Event-Name']
  event_issues = row['Event-Issues'].to_s.split('; ').map(&:strip)
  min_students = row['Min-Students'].to_i
  max_students = row['Max-Students'].to_i

  if event_issues.length >= 1 && event_issues.length <= 3
    event[event_id] = {
      'Event-Name' => event_name,
      'Event-Issues' => event_issues,
      'Min-Students' => min_students,
      'Max-Students' => max_students
    }
  else
    # Handle or ignore events that do not meet the criteria
    puts "Event ID '#{event_id}' is not stored because it does not have the required number of event issues."
  end
end
# # checks if there are valid number of event_issues read from the input file
# event.each do |event_id, event_data|
#   event_issues = event_data['Event-Issues']

#   if event_issues.length < 1 || event_issues.length > 3
#     # Remove the event ID from event hash
#     event.delete(event_id)
#     puts "Removed Event ID '#{event_id}' because it does not have the required number of event issues (1-3)."
#   end
# end

#initialzing student hashmaps
student = {}

CSV.foreach("/home/student1/vm-csc415/assignment1/students.csv", headers: true) do |row|
  student_id = row['Student-Id']
  interests = row['Interests'].split('; ').map(&:strip)
  
  student[student_id]= {
    'Interests' => interests
  }
end

# Iterate through the 'event' hash to add 'assigned_students' element to each event
event.each do |event_id, event_data|
  assigned_students = 0
  event_data['Assigned-Students'] = assigned_students
end

# Initialize a hash to store matching events for each student
matching_events = {}

# Iterate through each student
student.each do |student_id, student_data|
  student_interests = student_data['Interests']

  # Initialize an array to store matching event IDs for this student
  matching_event_ids = []

  # Iterate through each event
  event.each do |event_id, event_data|
    event_issues = event_data['Event-Issues']
    min_students = event_data['Min-Students']
    max_students = event_data['Max-Students']
    assigned_students = event_data['Assigned-Students']

    # Check if there's an intersection between event_issues and student_interests
    if (event_issues & student_interests).any?
      # Check if the event has available capacity
      if (max_students >= assigned_students && min_students != assigned_students)
        matching_event_ids << event_id
        event[event_id]['Assigned-Students'] += 1
        break
        
      end
    end
  end

  # Store the matching event IDs for this student
  matching_events[student_id] = matching_event_ids
end

# Iterate through the 'matching_events' hash and print the results
matching_events.each do |student_id, event_id|
  if event_id.empty?
    puts "Student ID: #{student_id} - No matching events"
  else
    event_names = event_id.map { |event_id| event[event_id]['Event-Name'] }.join(', ')
    puts "Student ID: #{student_id} - Matched Event: #{event_names}"
  end
end

puts event
