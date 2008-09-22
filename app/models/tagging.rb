class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  
  validates_presence_of :tag, :taggable
  before_create :check_for_synonyms

  def valid_tag
    return tag if tag && !tag.banned?
  end
  
  def self.tagees(options = {})
    with_scope :find => options do
      find(:all).collect(&:taggable).compact
    end
  end
  
  def self.find_by_category(category, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tags.tag_category_id = ?", category.id])
    end
  end

  def self.find_by_tag(tag, options = {})
    with_scope :find => options do
      find(:all, :include => :tag, :conditions => ["tags.id = ?", tag.id])
    end
  end
  
  # Tag with canonical synonym instead, if it exists
  def check_for_synonyms
    synonym = self.tag.canonical_synonym
    self.tag = synonym if synonym
  end

end
