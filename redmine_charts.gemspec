# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redmine_charts}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Maciej Szczytowski"]
  s.date = %q{2012-08-03}
  s.description = %q{Plugin for Redmine which integrates some nice project charts.}
  s.email = %q{mszczytowski@gmail.com}
  s.files = [
    "app/controllers/charts_burndown2_controller.rb",
    "app/controllers/charts_burndown_controller.rb",
    "app/controllers/charts_controller.rb",
    "app/controllers/charts_deviation_controller.rb",
    "app/controllers/charts_inflow_controller.rb",
    "app/controllers/charts_issue_controller.rb",
    "app/controllers/charts_outflow_controller.rb",
    "app/controllers/charts_ratio_controller.rb",
    "app/controllers/charts_timeline_controller.rb",
    "app/controllers/charts_worklist_controller.rb",
    "app/helpers/charts_helper.rb",
    "app/models/chart_done_ratio.rb",
    "app/models/chart_issue_entry.rb",
    "app/models/chart_issue_status.rb",
    "app/models/chart_saved_condition.rb",
    "app/models/chart_time_entry.rb",
    "assets/javascripts/charts.js",
    "config/locales/cs.yml",
    "config/locales/da.yml",
    "config/locales/de.yml",
    "config/locales/en.yml",
    "config/locales/es.yml",
    "config/locales/fr.yml",
    "config/locales/ja.yml",
    "config/locales/ko.yml",
    "config/locales/nl.yml",
    "config/locales/pl.yml",
    "config/locales/pt-BR.yml",
    "config/locales/ru.yml",
    "config/locales/sv.yml",
    "config/routes.rb",
    "db/migrate/20100222185306_create_chart_time_entries.rb",
    "db/migrate/20100222185307_create_chart_done_ratios.rb",
    "db/migrate/20100222185308_create_chart_issue_statuses.rb",
    "db/migrate/20100407184912_create_chart_saved_conditions.rb",
    "lib/redmine_charts.rb",
    "lib/redmine_charts/conditions_utils.rb",
    "lib/redmine_charts/grouping_utils.rb",
    "lib/redmine_charts/issue_patch.rb",
    "lib/redmine_charts/line_data_converter.rb",
    "lib/redmine_charts/pagination_utils.rb",
    "lib/redmine_charts/pie_data_converter.rb",
    "lib/redmine_charts/range_utils.rb",
    "lib/redmine_charts/stack_data_converter.rb",
    "lib/redmine_charts/time_entry_patch.rb",
    "lib/redmine_charts/utils.rb",
    "lib/tasks/migrate.rake",
    "lib/tasks/test.rake"
  ]
  s.homepage = %q{http://github.com/mszczytowski/redmine_charts/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Plugin for Redmine which integrates some nice project charts.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

