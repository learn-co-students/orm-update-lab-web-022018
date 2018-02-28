require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name,:grade,:id

  def initialize(name,grade,id=nil)
    @name=name
    @grade=grade
    @id=id
  end
  # THE .CREATE_TABLE METHOD
  # This class method creates the students table with columns that match the attributes of our individual students:
   # an id (which is the primary key), the name and the grade.
  def self.create_table
    sql = <<-SQL
      create table if not exists students(
        id INTEGER PRIMARY KEY,
        name text,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end
  # THE .DROP_TABLE METHOD
  # This class method should be responsible for dropping the students table.
  def self.drop_table
    DB[:conn].execute("drop table students")
  end
  # THE #SAVE METHOD
  # This instance method inserts a new row into the database using the attributes of the given object.
  # This method also assigns the id attribute of the object once the row has been inserted into the database.
  def save
    if @id
      DB[:conn].execute("update students set name = ? where id = ?", @name,@id)
      DB[:conn].execute("update students set grade = ? where id = ?", @grade,@id)
    else
      DB[:conn].execute("insert into students (name,grade) values( ?,? )",@name,@grade)
      @id=DB[:conn].execute("select last_insert_rowID() from students")[0][0]
    end
  end
  # THE .CREATE METHOD
  # This method creates a student with two attributes, name and grade.
  def self.create(name,grade)
    object = self.new(name,grade)
    object.save
  end
  # THE .NEW_FROM_DB METHOD
  # This class method takes an argument of an array. When we call this method we will pass it the array that is
  # the row returned from the database by the execution of a SQL query. We can anticipate that this array will
  # contain three elements in this order: the id, name and grade of a student.
  def self.new_from_db(row)
    student = Student.new(row[1],row[2],row[0])
  end
  # The .new_from_db method uses these three array elements to create a new Student object with these attributes.
  #
  # THE .FIND_BY_NAME METHOD
  # This class method takes in an argument of a name. It queries the database table for a record that has a name of
  # the name passed in as an argument. Then it uses the #new_from_db method to instantiate a Student object with the
  # database row that the SQL query returns.
  def self.find_by_name(name)
    row=DB[:conn].execute("select * from students where name = ?",name)[0]
    # puts "************#{row}"
    self.new_from_db(row)
  end
  #
  # THE #UPDATE METHOD
  # This method updates the database row mapped to the given Student instance.
  def update
    DB[:conn].execute("UPDATE students SET name = ? WHERE id = ?", @name, @id)
    DB[:conn].execute("UPDATE students SET grade = ? WHERE id = ?", @grade, @id)
  end
end
