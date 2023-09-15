
=begin
Ifrah Malik
CSC415-01 Software Engineering
Dr. Pulimood
Assignment 1
=end

require 'csv'

#initialzing hashmaps
event = {}

CSV.foreach("/home/student1/vm-csc415/assignment1/events.csv", headers: true) do |row|
  event_id = row['Event-ID']
  event_name = row['Event-Name']
  event_issues = row['Event-Issues'].split('; ').map(&:strip)
  min_students = row['Min-Students'].to_i
  max_students = row['Max-Students'].to_i

  event[event_id] = {
    'Event-Name' => event_name,
    'Event-Issues' => event_issues,
    'Min-Students' => min_students,
    'Max-Students' => max_students
  }
end

student = {}

CSV.foreach("/home/student1/vm-csc415/assignment1/studentInput.csv", headers: true) do |row|
  student_id = row['Student-Id']
  interests = row['Interests'].split('; ').map(&:strip)
  
  student[student_id]= {
    'Interests' => interests
  }
end


# puts event["4763"]
# puts student["18673"]

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

    # Check if there's an intersection between event_issues and student_interests
    if (event_issues & student_interests).any?
      matching_event_ids << event_id
    end
  end

  # Store the matching event IDs for this student
  matching_events[student_id] = matching_event_ids
end

# Now, 'matching_events' contains the matching event IDs for each student
matching_events.each do |student_id, event_ids|
  student_data = student[student_id]
  student_interests = student_data['Interests']

  puts "Student ID: #{student_id}"
  puts "Interests: #{student_interests.join(', ')}"
  
  if event_ids.empty?
    puts "No matching events found for this student."
  else
    puts "Matching Event IDs: #{event_ids.join(', ')}"
  end

  puts "\n"  # Add a newline for separation
end



