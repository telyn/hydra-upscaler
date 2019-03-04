# frozen_string_literal: true

require 'json'

module Zeebe
  # Here's an example Zeebe Worker which does a very simple transform on the
  # input document - setting .hello to 'world'
  #
  # ```ruby
  # class MyWorker
  #   include Zeebe::Worker
  #   task_type :my_task_type
  #
  #   def run
  #     document['hello'] = 'world'
  #   end
  # end
  #
  # puts MyWorker.run('{"hi": "hello"}')
  # ```
  # output: {"hi":"hello", "hello": "world"}
  #
  module Worker
    module ClassMethods
      def task_type(type = nil)
        @task_type ||= (type || :default)
      end

      def run(document)
        svc = new(document)
        svc.run
        JSON.generate(svc.document)
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.attr_reader :document
    end

    def initialize(document)
      @document = JSON.parse(document)
    end
  end
end
