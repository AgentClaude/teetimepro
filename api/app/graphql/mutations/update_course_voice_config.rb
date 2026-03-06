module Mutations
  class UpdateCourseVoiceConfig < BaseMutation
    argument :course_id, ID, required: true
    argument :system_prompt, String, required: false
    argument :greeting, String, required: false
    argument :voice_model, String, required: false
    argument :llm_provider, String, required: false
    argument :llm_model, String, required: false

    field :course, Types::CourseType, null: true
    field :errors, [String], null: false

    def resolve(course_id:, **args)
      require_auth!
      require_role!(:manager)

      course = current_organization.courses.find(course_id)
      config = course.voice_config || {}

      args.compact.each do |key, value|
        config[key.to_s] = value
      end

      if course.update(voice_config: config)
        { course: course, errors: [] }
      else
        { course: nil, errors: course.errors.full_messages }
      end
    end
  end
end
