class Feed < ActiveRecord::Base
	belongs_to :profile, :foreign_key => 'sender_id'
	belongs_to :app#, :foreign_key => 'app_id'
    belongs_to :resource, :polymorphic => true
    
    belongs_to :company
	belongs_to :campaign

    #validates_inclusion_of :sender_type, :in => [:generic, :user, :company, :campaign]
    #
    #def sender_type
    #    read_attribute(:sender_type).to_sym
    #end
    #
    #def sender_type= (value)
    #    write_attribute(:sender_type, value.to_s)
    #end

	# static: gets the db feed for the given profile (temp only, use no-sql)
	def Feed.get_feed(args)
        feed_sender, prefix_group, suffix_group, only_app, only_res = '', '', '', '', ''

		per_page = (args[:per_page] or 5)
		per_page = 10 if per_page > 10
		order = (args[:order] or 'created_at DESC')

        base_args = { :limit => per_page,
                      :order => order,
                      :include => [{:profile => [:resource, :profile_photo]},
                                    :app,
                                    :resource ]}

        pk_col_feed = args[:by_account] ? 'account' : 'sender'
        pk_col_fav = args[:by_account] ? 'account' : 'profile'
        
        only_res = ActiveRecord::Base.send(:sanitize_sql_array,
                        [") AND (resource_type = ?", args[:resource_type]]) if args[:resource_type]

        only_app = ActiveRecord::Base.send(:sanitize_sql_array,
                        [") AND (app_id = ?", args[:app_id].to_i]) unless ['all-apps', 0, nil].include?(args[:app_id])

        start_from = ActiveRecord::Base.send(:sanitize_sql_array,
                        [") AND (feeds.id < ?", args[:last_id].to_i]) if args[:last_id]

        feed_sender = ActiveRecord::Base.send(:sanitize_sql_array,
                                             ["#{pk_col_feed}_id = ?", args[:my_id]]) if args[:my_id]

		if args[:grouped_view] == true
            prefix_group = "(SELECT * FROM feeds WHERE ("
            suffix_group = ") ORDER BY #{order}) AS t1"
		end
		
        if args[:only_myself] == true
            # if we need only senders feed (either by sender_id (profile) or by account_id)
            conditions = ["#{pk_col_feed}_id = ?#{only_app}#{only_res}#{start_from}", args[:my_id]]
        else
            if args[:public_view] == true
                conditions = ["id > 0#{only_app}#{only_res}#{start_from}"]
            else
                # if we need only other feed or + my feed
                inc_my_feed = args[:include_me] ? " OR #{feed_sender}" : ''
                conditions = ["#{prefix_group}sender_id IN (SELECT receiver_profile_id AS sender_id
                                FROM favorites WHERE sender_#{pk_col_fav}_id = ?)
                                #{inc_my_feed}#{only_app}#{only_res}#{start_from}#{suffix_group}", args[:my_id]]
            end
        end
    
        custom_args ||= {:conditions => conditions}
		
		if args[:grouped_view] == true
            ext_args = {} # :having => (args[:last_id] ? "id < #{args[:last_id].to_i}" : nil) }
            
            if args[:only_myself] == true
                ext_args.merge!({ :group => 'app_id' })
                custom_args = {:from => ActiveRecord::Base.send(:sanitize_sql_array,
                                        ["(SELECT * FROM feeds WHERE (#{pk_col_feed}_id = ?#{only_app}#{only_res}#{start_from})
                                         ORDER BY #{order}) AS t1", args[:my_id]]) }.merge!(ext_args)
            else
                ext_args.merge!({ :group => args[:group_by] })
                custom_args = {:from => ActiveRecord::Base.send(:sanitize_sql_array,
                                        conditions)}.merge!(ext_args)
            end
		end

        Feed.all(base_args.merge!(custom_args))
	end

end
