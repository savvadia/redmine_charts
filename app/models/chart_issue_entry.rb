class ChartIssueEntry < ActiveRecord::Base

  belongs_to :issue

  def self.get_inflow_timeline(raw_group, raw_conditions, range)
    group = RedmineCharts::GroupingUtils.to_column(raw_group, "issues")

    conditions = {}

    raw_conditions.each do |c, v|
      column_name = RedmineCharts::ConditionsUtils.to_column(c, "issues")
      conditions[column_name] = v if v and column_name
    end

    joins = "left join issues on issues.id = issue_id"

    unless range
      row = Issue.first(:select => "YEAR(created_on)*1000+MONTH(created_on) as month, YEAR(created_on)*1000+WEEK(created_on,1) as week, YEAR(created_on)*1000+DAYOFYEAR(created_on) as day", :conditions => ["issues.project_id in (?)", conditions['project_id']], :readonly => true, :order => "1 asc, 2 asc, 3 asc")
      
      if row
        range = RedmineCharts::RangeUtils.propose_range({ :month => row.month, :week => row.week, :day => row.day })
      else
        range = RedmineCharts::RangeUtils.default_range
      end
    end

    range = RedmineCharts::RangeUtils.prepare_range(range)
    
    range[:column] = RedmineCharts::ConditionsUtils.to_column(range[:range], "issues")

	case range[:range]
	when :days
	  range_value = "YEAR(created_on)*1000+DAYOFYEAR(created_on)"
	  range[:column] = "day"
	when :weeks
	  range_value = "YEAR(created_on)*1000+WEEK(created_on,1)"
	  range[:column] = "week"
	when :months
	  range_value = "YEAR(created_on)*1000+MONTH(created_on)"
	  range[:column] = "month"
	else
	  puts "ChartIssueEntry:get_inflow_timeline() You gave me #{range[:range]} -- I have no idea what to do with that."
	  range_value = "YEAR(created_on)*1000+WEEK(created_on,1)"
	  range[:column] = "week"
	end

    select = "#{range_value} as range_value, '#{range[:range]}' as range_type, count(*) as entries, '#{raw_group}' as grouping"

    if group
      select << ", #{group} as group_id"
    else
      select << ", 0 as group_id"
    end
	
    grouping = (group ? group : "project_id")
    grouping << ", range_value HAVING range_value BETWEEN #{range[:min]} AND #{range[:max]}"
    
    rows = Issue.all(:select => select, :conditions => conditions, :readonly => true, :group => grouping, :order => "1 asc, 5 asc")

    rows.each do |row|
      row.group_id = '0' unless row.group_id
      # puts "ChartIssueEntry:get_inflow_timeline():: row=" << row.range_value.inspect << ", #=" << row.entries.inspect << ", groupId=" << row.group_id
    end

    [rows, range]
  end

  def self.get_outflow_timeline(raw_group, raw_conditions, range)
    group = RedmineCharts::GroupingUtils.to_column(raw_group, "issues")

    conditions = {}

    raw_conditions.each do |c, v|
      column_name = RedmineCharts::ConditionsUtils.to_column(c, "issues")
      conditions[column_name] = v if v and column_name
    end

    joins = "left join journal_details on journals.id = journal_details.journal_id left join issue_statuses on journal_details.value=issue_statuses.id left join issues on issues.id = journalized_id"

    unless range
      row = Journal.first(:select => "YEAR(journals.created_on)*1000+MONTH(journals.created_on) as month, YEAR(journals.created_on)*1000+WEEK(journals.created_on,1) as week, YEAR(journals.created_on)*1000+DAYOFYEAR(journals.created_on) as day", :conditions => ["prop_key = 'status_id' AND issue_statuses.is_closed = 1 AND journalized_type = 'Issue' AND issues.project_id in (?)", conditions['project_id']], :joins => joins, :readonly => true, :order => "1 asc, 2 asc, 3 asc")
      
      if row
        range = RedmineCharts::RangeUtils.propose_range({ :month => row.month, :week => row.week, :day => row.day })
      else
        range = RedmineCharts::RangeUtils.default_range
      end
    end

    range = RedmineCharts::RangeUtils.prepare_range(range)
    
    range[:column] = RedmineCharts::ConditionsUtils.to_column(range[:range], "issues")

	case range[:range]
	when :days
	  range_value = "YEAR(journals.created_on)*1000+DAYOFYEAR(journals.created_on)"
	  range[:column] = "day"
	when :weeks
	  range_value = "YEAR(journals.created_on)*1000+WEEK(journals.created_on,1)"
	  range[:column] = "week"
	when :months
	  range_value = "YEAR(journals.created_on)*1000+MONTH(journals.created_on)"
	  range[:column] = "month"
	else
	  puts "ChartIssueEntry:get_outflow_timeline() You gave me #{range[:range]} -- I have no idea what to do with that."
	  range_value = "YEAR(journals.created_on)*1000+WEEK(journals.created_on,1)"
	  range[:column] = "week"
	end

    select = "#{range_value} as range_value, '#{range[:range]}' as range_type, count(*) as entries, '#{raw_group}' as grouping"

    if group
      select << ", #{group} as group_id"
    else
      select << ", 0 as group_id"
    end
	
    grouping = (group ? group : "project_id")
    grouping << ", range_value HAVING range_value BETWEEN #{range[:min]} AND #{range[:max]}"

    conditions['journals.journalized_type'] = 'Issue'
    conditions['journal_details.prop_key']  = 'status_id'
    conditions['issue_statuses.is_closed']  = 1

    rows = Journal.all(:select => select, :joins => joins, :conditions => conditions, :readonly => true, :group => grouping, :order => "1 asc, 5 asc")

    rows.each do |row|
      # puts "ChartIssueEntry:get_outflow_timeline():: row=" << row.range_value.inspect << ", #=" << row.entries.inspect
      row.group_id = '0' unless row.group_id
    end

    [rows, range]
  end

  def self.snapshot_till(raw_group, raw_conditions, range)
    
    rows_snap = {}
    return rows_snap unless range

    # inflow snapshot
    group = RedmineCharts::GroupingUtils.to_column(raw_group, "issues")

    select = "count(*) as entries"
    if group
      select << ", #{group} as group_id"
    else
      select << ", 0 as group_id"
    end
	
    grouping = (group ? group : "project_id")

	case range[:range]
	when :days   then date_min = Date.strptime(range[:min], "%Y%j")
	when :weeks  then date_min = Date.strptime(range[:min], "%G0%V")
	when :months then date_min = Date.strptime(range[:min], "%Y0%m")
	else
		flash[:error] = "Couldn't identify date range " << range[:range].to_s
		return rows_snap 
	end

    conditions = {}

    raw_conditions.each do |c, v|
      column_name = RedmineCharts::ConditionsUtils.to_column(c, "issues")
      conditions[column_name] = v if v and column_name
    end

    conditions['created_on'] = Date.new(1900, 1, 1) .. date_min
    
	rows_in = Issue.all(
	  :readonly => true,
	  :select => select,
	  :conditions => conditions,
	  :group  => grouping
	)
	
    rows_in.each do |row|
      row.group_id = '0' unless row.group_id
      group_name = RedmineCharts::GroupingUtils.to_string(row.group_id, raw_group)
      # puts "snapshot_till():: row TRs=" << row.entries.inspect << ", group=" << row.group_id.inspect << ", group_name=" << group_name
	  rows_snap[group_name] ||= 0
	  rows_snap[group_name] += row.entries.to_i
    end
    
    # outflow snapshot
    joins = "left join journal_details on journals.id = journal_details.journal_id left join issue_statuses on journal_details.value=issue_statuses.id left join issues on issues.id = journalized_id"

    conditions.delete('created_on')
    conditions['journals.journalized_type'] = 'Issue'
    conditions['journal_details.prop_key']  = 'status_id'
    conditions['issue_statuses.is_closed']  = 1
    conditions['journals.created_on'] = Date.new(1900, 1, 1) .. date_min

    rows_out = Journal.all(
		:readonly => true,
		:select => select,
		:joins => joins,
		:conditions => conditions,
		:group => grouping)

    rows_out.each do |row|
      # puts "snapshot_till():: row TRs=" << row.entries.inspect << ", group=" << row.group_id.inspect
      row.group_id = '0' unless row.group_id
      group_name = RedmineCharts::GroupingUtils.to_string(row.group_id, @grouping)
	  rows_snap[group_name] ||= 0
	  rows_snap[group_name] -= row.entries.to_i
    end

    rows_snap
  end

  def self.get_aggregation_for_issue(raw_conditions, range)
    flash[:error] = "Aggregation is not supported"
    nil
  end

  def self.get_aggregation(raw_group, raw_conditions)
    flash[:error] = "Aggregation is not supported"
    nil
  end

end
