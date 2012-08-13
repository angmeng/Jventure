class BoardNotice < ActiveRecord::Base

  validates_presence_of :title, :content

  named_scope :top_three_recent, {:conditions => ["suspend = false"], :limit => 5, :order => "created_at DESC"}
  named_scope :top_fifty_recent, {:conditions => ["suspend = false"], :limit => 50, :order => "created_at DESC"}
  named_scope :public, {:conditions => ["public = true"]}
  named_scope :private, {:conditions => ["public = false"]}
end
