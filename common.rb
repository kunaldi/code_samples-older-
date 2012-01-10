module Common
    module Generic
        def self.included(recipient)
            recipient.extend(ClassMethods)
            recipient.class_eval do
                include InstanceMethods
            end
        end
    
        # Class Methods
        module ClassMethods
            def copy_instance_variables_from_object(obj)
                obj.instance_variables.each do |ivar|
                  instance_variable_set ivar, obj.instance_variable_get(ivar)
                end
            end
        
            def set_instance_variables_from_hash(hash)
                hash.each do |key, value|
                  instance_variable_set "@#{key}", value
                end
            end
        
            def return_object_or_raise(obj)
                result = yield
                if result.success?
                  result.send obj
                else
                  raise ValidationsFailed.new(result)
                end
            end
        
            def singleton_class
                class << self; self; end
            end    
        end
    
        # Instance Methods
        module InstanceMethods
            include IdTable
            
            def fetch_tab
                content, tabs = '', ''
                tab_id = params[:tab_id].to_s
                public_profile = true
        
                begin
                    raise 'post required' unless request.post?
                    
                    if params[:profile] == ID_TABLE[:profiles][:application]
                        v = populate_tab_data(:tab_id => tab_id,
                                              :app => params[:app])
    
                    elsif params[:profile] == ID_TABLE[:profiles][:item]
                        v = populate_tab_data(:tab_id => tab_id)
    
                    else
                        pid = params[:profile_id]
                        profile = Profile.find_by_id(pid)
                        resource = (profile.nil?) ? nil : profile.resource
                        raise 'no profile' if resource.nil?
            
                        if public_profile
                             # ...
                        else
                            raise 'not logged in' unless logged_in?
                            
                            unless profile.is_my_resource
                                profile.is_my_bookmark = Favorite.is_my_bookmark?(current_account.id, profile.id)
                                raise 'blocked' if Block.is_blocked?(resource.account_id, current_account.id)
                            end
                        end
                        
                        @profile = populate_profile_args(:profile => profile)
                        v = populate_tab_data(:tab_id => tab_id, :profile => profile)
                    end
                                    
                    @profile[tab_id] = v[:values] unless v[:values].nil?
                    content = render_to_string( :partial => v[:template], :locals => {} )
                    
                rescue Exception => e
                    #logger.warn e.backtrace
                    return {:code => 1, :error_msg => e.inspect, :backtrace => e.backtrace}.to_json
                end
                
                qry_tabs = 'profile-tabs ul.tab-buttons-small li a'
                
                return {:code => 0,
                        :cmds => [{	:target => qry_tabs,
                                    :data => 'selected',
                                    :action => 'remove-class'},
                                  {	:target => "#{qry_tabs}##{tab_id}",
                                    :data => 'selected',
                                    :action => 'add-class'},
                                  {	:target => 'panels-zone',
                                    :data => content,
                                    :action => 'html-quick'},
                                 ]}.to_json
            end
            
            def create_item
                begin
                    return redirect_to('/error') unless request.post?
                    
                    raise 'unavailable' unless check_availability()

                    Item.transaction do
                        item = current_user.items.create!(:item_name => params[:item_name],
                                                          :color => params[:color])
                        
                        # temp only, use no-sql
                        feed = Feed.new(:source_name => 'system',
                                        :source_id => item.id,
                                        :sender_id => current_user.id,
                                        :action_type => 'create',
                                        :target_type => 'item',
                                        :data => {:item_name => item.item_name}.to_json)
                        feed.save!
        
                        unless params[:tags].blank?
                            params[:tags].each do |tag_item|
                                tag = Tag.find_or_create_by_tag_name_and_tag_type(tag_item.capitalize,
                                                                                  TagTypes::Values[:item]) do |t|
                                    if tag.new_record?
                                        t.created_by_user_id = current_user.id 
                                        t.save
                                    end
                                end

                                item.tags << tag
                            end
                        end
                    end
                    
                rescue ActiveRecord::RecordInvalid => invalid
                    logger.error "Exception in [#{self.class.name}::create_item()] #{invalid.message}"
                    
                    error_list = render_to_string(:partial => "generic/inc_generic_form_error",
                                                  :object => invalid.record)
        
                    ajax_res = { :target => 'form-error', :data => error_list, :action => 'html-quick' }
                    
                #rescue RuntimeError=> e
                    # other error handling here
                #else
                ensure
                    return {:cmds => [ajax_res]}.to_json
                end
              
            end
            
        end
    end
end
