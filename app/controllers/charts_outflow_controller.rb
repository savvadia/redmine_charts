class ChartsOutflowController < ChartsController

  unloadable
  protected
  
  def get_data

    rows, @range = ChartIssueEntry.get_outflow_timeline(@grouping, @conditions, @range)

    sets = {}
    noOfEntriesPerSlot = {}
    max = 0

    if rows.size > 0
      rows.each do |row|
        group_name = RedmineCharts::GroupingUtils.to_string(row.group_id, @grouping)
        index = @range[:keys].index(row.range_value.to_s)
        if index
          sets[group_name] ||= Array.new(@range[:keys].size, [0, get_hints])
          sets[group_name][index] = [row.entries.to_i, get_hints(row.entries.to_i, group_name, @range[:labels][index], @range[:keys][index])]
          noOfEntriesPerSlot[index] ||= 0
          noOfEntriesPerSlot[index] += row.entries.to_i
          max = noOfEntriesPerSlot[index] if max < noOfEntriesPerSlot[index]
        else
          raise row.range_value.to_s
        end
      end
    else
      sets[""] ||= Array.new(@range[:keys].size, [0, get_hints])
    end

    sets = sets.sort.collect { |name, values| [name, values] }

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
    l(:charts_link_outflow)
  end
  
  def get_help
    l(:charts_outflow_help)
  end

  def get_type
    :stack
  end

  def get_x_legend
    l(:charts_outflow_x)
  end
  
  def get_y_legend
    l(:charts_outflow_y)
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
