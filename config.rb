activate :directory_indexes

# Data structure for creating pagination indexes. Format is a key paired with
# paths that will match the key.
pagination_indexes = {
  projects: []
}

data.projects.details.each do |project|
  project_slug = project[:slug]
  project_path = "#{project_slug}.html" # Don't use slashes at the start of the path

  proxy project_path, "project.html", locals: { project: project }, ignore: false

  # Build the pagination index for all projects
  pagination_indexes[:projects] << project_path

  # Create the patterns page
  patterns_paths = project.patterns.map do |pattern|
    path = "#{project_slug}/patterns/#{pattern[:bundle]}.html"
    
    proxy path, "patterns.html", ignore: false, locals: {
      pattern: pattern,
      project: project
    }
    
    path
  end

  # Build the pagination index for this project's patterns
  patterns_pagination_key = "#{project_slug}-patterns"
  pagination_indexes[patterns_pagination_key] = patterns_paths

  # Create the , with pagination metadata
  proxy "#{project_slug}/patterns.html", "patterns.html",
    locals: { project: project, haspatterns: true },
    pagination: { for: patterns_pagination_key, per_page: 2 },
    ignore: false

  project.patterns.each do |pattern|
    p = data.patterns.details.find { |x| x['bundle'] == pattern[:bundle] }

    pattern_paths = p.details.map do |single|
      path = "#{project_slug}/patterns/#{pattern[:bundle]}/#{single[:slug]}.html"

      proxy path, "pattern_single.html", ignore: false, locals: {
        single: single,
        pattern: pattern,
        project: project
      }

      path
    end


  end
end

activate :pagination do
  pagination_indexes.each do |category, paths|

    puts "Category: #{category.inspect}"
    puts "Paths: #{paths.inspect}"

    pageable category do |page|
      paths.include?(page.path)
    end

  end
end