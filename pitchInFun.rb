=begin
Ifrah Malik
CSC415-01 Software Engineering
Dr. Pulimood
Assignment 1
=end

require 'csv'

#initialzing hashmaps
event = {}

CSV.foreach("/home/student1/vm-csc415/assignment1/eventInput.csv", headers: true) do |row|
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

# Access the first record's values
# puts event["4763"]
# puts student["18673"]
