module NewRelicAWS
  module Collectors
    class S3 < Base
      def initialize(access_key, secret_key, region, options)
        region = options[:region]
        super(access_key, secret_key, region, options)
        @buckets = options[:buckets]
      end

      def metric_list
        [
          ["BucketSizeBytes", "Average", "Bytes", "StandardStorage"],
          ["NumberOfObjects", "Average", "Count", "AllStorageTypes"],
        ]
      end

      def collect
        data_points = []
        @buckets.each do |bucket|
          metric_list.each do |(metric_name, statistic, unit, storage_type)|
            now = DateTime.now - 1  # Date before.
            data_point = get_data_point(
              :namespace   => "AWS/S3",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimensions   => [
                {
                  :name  => "BucketName",
                  :value => bucket
                },
                {
                  :name  => "StorageType", 
                  :value => storage_type
                },
              ],
              :period => 86400,
              :start_time => DateTime.parse(now.strftime("%Y-%m-%dT00:00:00")).iso8601,
              :end_time => DateTime.parse(now.strftime("%Y-%m-%dT01:00:00")).iso8601,
              :component_name => bucket
            )
            NewRelic::PlatformLogger.debug("metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}")
            unless data_point.nil?
              data_points << data_point
            end
          end
        end
        data_points
      end
    end
  end
end
