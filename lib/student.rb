require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id 
  end

  def self.create_table
    sql_command = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql_command)
  end

  def self.drop_table
    sql_command = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql_command)
  end

  def save
    if self.id
      self.update
    else
      sql_command = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql_command, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    puts row;
    student = Student.new(row[0], row[1], row[2])
    # student.id = row[0]
    # student.name = row[1]
    # student.grade = row[2]
    student
  end

  def self.find_by_name(name)
    sql_command = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    SQL
    row_data = DB[:conn].execute(sql_command, name)[0]
    self.new(row_data[0], row_data[1], row_data[2])
  end

  def update
    sql_command = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql_command, self.name, self.grade, self.id)
  end

end
