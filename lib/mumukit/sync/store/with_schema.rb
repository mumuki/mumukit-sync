module Mumukit::Sync::Store::Github::WithSchema
  def exercise_schema
    Mumukit::Sync::Store::Github.config.exercise_schema
  end

  def guide_schema
    Mumukit::Sync::Store::Github.config.guide_schema
  end

  def build_fields_h(fields)
    fields.map { |field| [field.reverse_name, yield(field)] }.to_h
  end
end

