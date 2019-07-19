module NewRelicAWS
  module Collectors
    class CLOUDFRONT < Base
      def initialize(access_key, secret_key, region, options)
        super(access_key, secret_key, region, options)
        @distribution_ids = options[:distribution_ids]
      end

      def metric_list
        [
          ["5xxErrorRate", "Average", "Percent"],
          ["TotalErrorRate", "Average", "Percent"],
          ["4xxErrorRate", "Average", "Percent"],
          ["LambdaExecutionError", "Average", "None"],
          ["Requests", "Average", 'None']
        ]
      end

      def collect
        data_points = []
        @distribution_ids.each do |distribution_id|
          metric_list.each do |(metric_name, statistic, unit)|
            data_point = get_data_point(
              :namespace   => "AWS/CloudFront",
              :metric_name => metric_name,
              :statistic   => statistic,
              :unit        => unit,
              :dimensions  => [
                {
                  :name  => "DistributionId",
                  :value => distribution_id
                },
                {
                  :name  => "Region",
                  :value => "Global"
                }
              ],
            )
            NewRelic::PlatformLogger.debug(">> metric_name: #{metric_name}, statistic: #{statistic}, unit: #{unit}, response: #{data_point.inspect}")
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
