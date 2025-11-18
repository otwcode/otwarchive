# Workaround for rails-i18n 7.0.10 compatibility with Ruby 3.4
# The gem references RailsI18n::Pluralization which doesn't exist in the namespace
# See: https://github.com/svenfuchs/rails-i18n/issues/968

module RailsI18n
  module Pluralization
    # Arabic pluralization
    module Arabic
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          mod100 = n % 100

          case
          when n == 0 then :zero
          when n == 1 then :one
          when n == 2 then :two
          when (3..10).include?(mod100) then :few
          when (11..99).include?(mod100) then :many
          else :other
          end
        end
      end
    end

    # East Slavic (Russian, Ukrainian, Belarusian)
    module EastSlavic
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          mod10 = n % 10
          mod100 = n % 100

          case
          when mod10 == 1 && mod100 != 11 then :one
          when (2..4).include?(mod10) && !(12..14).include?(mod100) then :few
          else :many
          end
        end
      end
    end

    # West Slavic (Czech, Slovak)
    module WestSlavic
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          case n
          when 1 then :one
          when 2..4 then :few
          else :other
          end
        end
      end
    end

    # Romanian
    module Romanian
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          mod100 = n % 100

          case
          when n == 1 then :one
          when n == 0 || (1..19).include?(mod100) then :few
          else :other
          end
        end
      end
    end

    # Polish
    module Polish
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          mod10 = n % 10
          mod100 = n % 100

          case
          when n == 1 then :one
          when [2, 3, 4].include?(mod10) && ![12, 13, 14].include?(mod100) then :few
          else :many
          end
        end
      end
    end

    # Latvian
    module Latvian
      def self.rule
        lambda do |n|
          return :other unless n.is_a?(Numeric)

          mod10 = n % 10
          mod100 = n % 100

          case
          when n == 0 then :zero
          when mod10 == 1 && mod100 != 11 then :one
          else :other
          end
        end
      end
    end
  end
end
