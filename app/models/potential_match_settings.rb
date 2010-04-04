class PotentialMatchSettings < ActiveRecord::Base
  ALL = -1
  REQUIRED_MATCH_OPTIONS =  [
                              [t('potential_match_settings.all', :default => "All"), ALL],  
                              ["0", 0],  
                              ["1", 1],  
                              ["2", 2],  
                              ["3", 3],
                              ["4", 4],
                              ["5", 5]
                            ]
                           
end
