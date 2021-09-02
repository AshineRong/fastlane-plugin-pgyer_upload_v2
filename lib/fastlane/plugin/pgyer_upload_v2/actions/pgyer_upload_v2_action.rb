require 'fastlane/action'
require_relative '../helper/pgyer_upload_v2_helper'

require 'faraday'
require 'faraday_middleware'

module Fastlane
  module Actions
    class PgyerUploadV2Action < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # UI.message "Parameter API Token: #{params[:api_token]}"
        UI.message("The PgyerUploadV2 Action is working.")

        api_host = "https://www.pgyer.com/apiv2/app/upload"
        api_key = params[:api_key]
        # sh "shellcommand ./path"
        build_file = [
          params[:ipa],
          params[:apk]
        ].detect { |e| !e.to_s.empty? }

        if build_file.nil?
          UI.user_error!("You have to provide a build file")
        end

        UI.message "build_file: #{build_file}"

        buildPassword = params[:buildPassword]
        if buildPassword.nil?
          buildPassword = ""
        end

        buildUpdateDescription = params[:buildUpdateDescription]
        if buildUpdateDescription.nil?
          buildUpdateDescription = "PgyerSecond Action Default build_Update_Description "
        end

        buildInstallType = params[:buildInstallType]
        if buildInstallType.nil?
          buildInstallType = "1"
        end
        buildChannelShortcut = params[:buildChannelShortcut]

        # start upload
        conn_options = {
          request: {
            timeout:       1000,
            open_timeout:  300
          }
        }

        pgyer_client = Faraday.new(nil, conn_options) do |c|
          c.request :multipart
          c.request :url_encoded
          c.response :json, content_type: /\bjson$/
          c.adapter :net_http
        end

        params = {
            '_api_key' => api_key,
            'buildPassword' => buildPassword,
            'buildUpdateDescription' => buildUpdateDescription,
            'buildInstallType' => buildInstallType,
            'buildChannelShortcut' => buildChannelShortcut,
            'file' => Faraday::UploadIO.new(build_file, 'application/octet-stream')
        }

       
        if buildChannelShortcut.nil?
          # UI.message "🚑️🚑️ the buildChannelShortcut => #{buildChannelShortcut} 为nil 将其delete 🚑️🚑️🚑️"
          params.delete('buildChannelShortcut')
        else 
          UI.message "🚧 🚧🚧🚧 the buildChannelShortcut #{buildChannelShortcut}🚧🚧🚧🚧"   # 也可以动态添加 params.store("buildChannelShortcut", buildChannelShortcut) 
        end

        UI.message "Start upload #{build_file} to pgyer by APIV2..."
        # UI.message "🚀 🚀 Start upload #{params} to pgyer by APIV2...🚀"

        response = pgyer_client.post api_host, params
        info = response.body

        if info['code'] != 0
          UI.user_error!("PGYER Plugin Error: #{info['message']}")
        end

        UI.success "Upload success. Visit this URL to see: https://www.pgyer.com/#{info['data']['buildShortcutUrl']}"
        # Actions.lane_context[SharedValues::PGYER_V2_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "distribute app to pgyer_upload_v2 beta testing service"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "distribute app to pgyer_upload__v2 by API V2 beta testing service."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                  env_name: "FL_PGYER_UPLOAD_V2_API_KEY",
                               description: "api_key in your pgyer account",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :apk,
                                      env_name: "FL_PGYER_UPLOAD_V2_APK",
                                      description: "Path to your APK file",
                                      default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                      optional: true,
                                      verify_block: proc do |value|
                                        UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                      end,
                                      conflicting_options: [:ipa],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                      end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                      env_name: "FL_PGYER_UPLOAD_V2_IPA",
                                      description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file",
                                      default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                      optional: true,
                                      verify_block: proc do |value|
                                        UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                      end,
                                      conflicting_options: [:apk],
                                      conflict_block: proc do |value|
                                        UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                      end),
          FastlaneCore::ConfigItem.new(key: :buildPassword,
                                 env_name: "FL_PGYER_UPLOAD_V2_BUILD_Password",
                              description: "set buildPassword to protect app",
                                 optional: true,
                                     type: String),
         FastlaneCore::ConfigItem.new(key: :buildUpdateDescription,
                                 env_name: "FL_PGYER_UPLOAD_V2_BUILD_UPDATE_DESCRIPTION",
                              description: "set update description for app",
                                 optional: true,
                                     type: String),
          FastlaneCore::ConfigItem.new(key: :buildInstallType,
                                 env_name: "FL_PGYER_UPLOAD_V2_BUILD_INSTALL_TYPE",
                              description: "set install type for app (1=public, 2=password, 3=invite). Please set as a string",
                                 optional: true,
                                    type: String),
          FastlaneCore::ConfigItem.new(key: :buildChannelShortcut,
                                 env_name: "FL_PGYER_UPLOAD_V2_BUILD_CHANNEL_SHORTCUT",
                              description: "set the download short link of designated channel. MUST Sure the channel  exsit ",
                                 optional: true,
                                    type: String)
                                             
         
          # FastlaneCore::ConfigItem.new(key: :api_token,
          #                              env_name: "FL_PGYER_UPLOAD_V2_API_TOKEN", # The name of the environment variable
          #                              description: "API Token for PgyerV2Action", # a short description of this parameter
          #                              verify_block: proc do |value|
          #                                 UI.user_error!("No API token for PgyerV2Action given, pass using `api_token: 'token'`") unless (value and not value.empty?)
          #                                 # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
          #                              end),
          # FastlaneCore::ConfigItem.new(key: :development,
          #                              env_name: "FL_PGYER_UPLOAD_V2_DEVELOPMENT",
          #                              description: "Create a development certificate instead of a distribution one",
          #                              is_string: false, # true: verifies the input is a string, false: every kind of value
          #                              default_value: false) # the default value if the user didn't provide one
        ]
      end

      # def self.output
      #   # Define the shared values you are going to provide
      #   # Example
      #   [
      #     ['PGYER_V2_CUSTOM_VALUE', 'A description of what this value contains']
      #   ]
      # end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Jiahao"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end

# class PgyerUploadV2Action < Action
#   def self.run(params)
#     UI.message("The pgyer_upload_v2 plugin is working!")
#   end

#   def self.description
#     "distribute app to pgyer by API V2"
#   end

#   def self.authors
#     ["gongjiahao"]
#   end

#   def self.return_value
#     # If your method provides a return value, you can describe here what it does
#   end

#   def self.details
#     # Optional:
#     "distribute app to pgyer by API V2 beta testing service"
#   end

#   def self.available_options
#     [
#       # FastlaneCore::ConfigItem.new(key: :your_option,
#       #                         env_name: "PGYER_UPLOAD_V2_YOUR_OPTION",
#       #                      description: "A description of your option",
#       #                         optional: false,
#       #                             type: String)
#     ]
#   end

#   def self.is_supported?(platform)
#     # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
#     # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
#     #
#    [:ios, :mac, :android].include?(platform)
#     true
#   end
# end