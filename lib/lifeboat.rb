# SAMPLE USAGE ########################
#######################################
# class AnyObject < ActiveRecord::Base
#  include LifeBoat
#
#  lifeboat.configure do |config|
#     config.delete :ignore
#  end
# end

# LIFEBOATS ###########################
#######################################
#
# - reads all attributes from included object
# - creates simpleDB objects when parent object is created
# - updates simpleDB objects when parent object is updated
# - deletes simpleDB objects when parent object is deleted
#
#######################################

