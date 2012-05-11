module ReviewHelper
  def star_count (id, stars, options = {})
    render :partial => 'stars', :locals => options.merge({
      :id => id, :read_only => true, :score => stars
      })
  end

  # to be called from within the scope of form_for
  def star_rating (form, field_name, options = {})
    full_name = "#{form.object_name}[#{field_name}]"
    star_rating_tag(full_name, options)
  end

  # options:
  #   id: span element's html id (has smart default)
  #   class: span element's html class (auto-includes 'star-rating')
  #   hints: (roll-over text), e.g. [bad,meh,ok,good,great]
  #   cancel: true if you want a cancel button
  #   cancel_place: 'left' or 'right'
  def star_rating_tag (name, options = {})
    # select_tag name, options_for_select((1..max_stars).map{|x| [x,x]}.to_a, 3)
    render :partial => 'stars', :locals => options.merge({:field_name => name.to_s})
  end

  # TODO format grade according to above/below/at median
  def letter_grade (raw_grade, median = 8)
    Review.letter_grade(raw_grade+1) || '?'
  end

  def reasons_tag(name, selected_field = :for_interest)
    reasons = [
      ['Interest',:for_interest],
      ['Major/Minor',:for_major],
      ['Distrib/WC', :for_distrib],
      ['Prof',:for_prof],
      ['Easy A',:for_easy_a],
      ['Prereqs',:for_prereqs]
    ]
    select_tag name, options_for_select(reasons, selected_field)
  end

end
