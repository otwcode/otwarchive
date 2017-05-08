# frozen_string_literal: true
# There's also Active Record serializer which allows you to pass 
# AR models directly as arguments. To use it just do:

Resque::Mailer.argument_serializer = Resque::Mailer::Serializers::ActiveRecordSerializer
