class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = Student.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2].to_i
    return student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
        SELECT *
        FROM students
      SQL
    DB[:conn].execute(sql).map do |student|
      self.new_from_db(student)
    end
  end

  def self.all_students_in_grade_9
    self.all.select do |student|
      student.grade == 9
    end
  end

  def self.students_below_12th_grade
    self.all.select do |student|
      student.grade.to_i < 12
    end
  end

  def self.first_X_students_in_grade_10(x)
    tenth_graders = self.all.select do |student|
      student.grade == 10
    end
    tenth_graders[0...x]
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1).first
  end

  def self.all_students_in_grade_X(x)
    self.all.select do |student|
      student.grade == x
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
        SELECT * 
        FROM students
        WHERE name = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |student|
        self.new_from_db(student)
      end.first

  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
