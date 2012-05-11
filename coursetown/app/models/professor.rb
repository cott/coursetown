class Professor < ActiveRecord::Base
  has_many :offering_professors
  has_many :offerings, :through => :offering_professors
  has_many :reviews, :through => :offerings

  validates :name, :presence => true
  validates :last_name, :presence => true

  # NOTE: Professor model should store profs' FULL NAMES. Including initials.
  # sometimes (e.g. when importing CourseGuide) we have a shorter name.

  # if last name isn't set manually, figure it out from the full name
  before_validation do
    return false if self.name.nil?
    if self.last_name.nil? || self.last_name.empty?
      names = self.class.important_names(self.name)
      self.last_name = names[-1] if !names.empty?
    end
    true
  end

  # find_by_fuzzy_name('John Doe') --> <prof name => 'John A. Doe III'>
  # assumes arg is subset of solution. 'John A. Doe III' won't find 'John Doe'
  def self.find_by_fuzzy_name(fuzzy_name)
    names = fuzzy_name.split(' ')
    inames = important_names(fuzzy_name)
    last_name = inames[-1]
    matches = self.find_all_by_last_name(last_name)
    return nil if matches.empty?

    # try to match the name perfectly
    perfect_matches = matches.select{|x| x.name == fuzzy_name}
    puts "WARNING: multiple professors match name #{fuzzy_name}" if perfect_matches.size > 1
    return perfect_matches.first if perfect_matches.size >= 1

    # else check for something that includes the first name
    perfect_matches = matches.select do |match|
      nameset = match.name.split(' ')
      i = -1
      # check that the full name includes all the other names AND
      # that the names appear in the correct order
      names.all? do |nom|
        j = nameset.find_index nom
        i && j && j > i && (i = j) # awkward to avoid explicit returns...
      end
    end

    puts "WARNING: multipe professors are fuzzy matches for name #{fuzzy_name}" if perfect_matches.size > 1
    return perfect_matches.first # might return nil
  end

  # John A. Doe III => [John,Doe]
  def self.important_names(full_name)
    names = full_name.split(' ')
    important_names = names.select do |str|
      !((str.size == 2 && str[-1] == '.') || # initials
        (str.size > 1 && str.upcase == str) || # roman numerals (all upcase)
        (str == 'Jr.' || str == 'Sr.'))
    end
  end

  # John A. Doe III => John Doe
  def self.short_name(full_name)
    important_names(full_name).join(' ')
  end
end
