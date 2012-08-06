class ChartsWorklistController < ChartsController

  unloadable
  protected
  
  def get_data

    rows_in,  range_in  = ChartIssueEntry.get_inflow_timeline(@grouping, @conditions, @range)
    rows_out, range_out = ChartIssueEntry.get_outflow_timeline(@grouping, @conditions, @range)

	@range = range_in
    rows_snap = ChartIssueEntry.snapshot_till(@grouping, @conditions, @range)

	@range = range_in
    groups = []
    sets = {}
    order = {}
    max = 0

    if rows_in.size > 0 or rows_out.size > 0
      rows_in.each do |row|
        group_name, order[group_name] = RedmineCharts::GroupingUtils.to_string_and_order(row.group_id, @grouping)
        index = @range[:keys].index(row.range_value.to_s)
        if index
          sets[group_name] ||= Array.new(@range[:keys].size, [0, ""])
          entries = sets[group_name][index][0] + row.entries.to_i
          sets[group_name][index] = [entries, ""]
        else
          raise row.range_value.to_s
        end
      end

      rows_out.each do |row|
        group_name, order[group_name] = RedmineCharts::GroupingUtils.to_string_and_order(row.group_id, @grouping)
        index = @range[:keys].index(row.range_value.to_s)
        if index
          sets[group_name] ||= Array.new(@range[:keys].size, [0, ""])
          entries = sets[group_name][index][0] - row.entries.to_i
          sets[group_name][index] = [entries, ""]
        else
          raise row.range_value.to_s
        end
      end
    else
      sets[""] ||= Array.new(@range[:keys].size, [0, get_hints])
    end

    noOfEntriesPerSlot = {}
    max = 0

    if sets.keys.size > 0
	  sets.keys.each do | group_name |
		  prev_value = (rows_snap.include? group_name) ? rows_snap[group_name] : 0
		  (0..@range[:keys].size-1).each do |index|
			entries = sets[group_name][index][0] + prev_value
            sets[group_name][index] = [entries, get_hints(entries, group_name, @range[:labels][index], @range[:keys][index])]
			prev_value = entries
            noOfEntriesPerSlot[index] ||= 0
            noOfEntriesPerSlot[index] += prev_value
            max = noOfEntriesPerSlot[index] if max < noOfEntriesPerSlot[index]
          end
	  end
    end 

    sets = sets.sort_by{ |name, values| [order[name], name] }.collect { |name, values| [name, values] }
	
    {
      :labels => @range[:labels],
      :count => @range[:keys].size,
      :max => max,
      :sets => sets
    }
  end

  def get_hints(entries = nil, group = "", range = "", key = "")
    unless entries.nil?
      l(:charts_worklist_hint, { :trs => entries.to_s, :group => group, :range => range, :key => key })
    else
      l(:charts_worklist_hint_empty)
    end
  end

  def get_title
    l(:charts_link_worklist)
  end
  
  def get_help
    l(:charts_worklist_help)
  end

  def get_type
    :stack
  end

  def get_x_legend
    l(:charts_worklist_x)
  end
  
  def get_y_legend
    l(:charts_worklist_y)
  end

  def show_date_condition
    true
  end

  def get_grouping_options
    [ :none, :user_id, :author_id, :assigned_to_id, :issue_id, :category_id, :priority_id, :tracker_id, :fixed_version_id, :project_id, :status_id ]
  end

  def get_multiconditions_options
    [ :project_ids, :user_ids, :category_ids, :status_ids, :fixed_version_ids, :tracker_ids, :priority_ids, :author_ids, :assigned_to_ids ]
  end

end
