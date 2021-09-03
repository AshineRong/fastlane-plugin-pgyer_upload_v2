# pgyer_upload_v2 plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-pgyer_upload_v2)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-pgyer_upload_v2`, add it to your project by running:

```bash
fastlane add_plugin pgyer_upload_v2
```

## About pgyer_upload_v2

distribute app to pgyer by API V2

**Note to author:** Add a more detailed description about this plugin here. If your plugin contains multiple actions, make sure to mention them here.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

Just specify the `api_key` and `user_key` associated with your pgyer account.

```
lane :beta do
  gym
  pgyer_upload_v2(api_key: "7f15xxxxxxxxxxxxxxxxxx141")
end
```

You can also set a password to protect the App from being downloaded publicly:

```
lane :beta do
  gym
  pgyer_upload_v2(api_key: "7f15xxxxxxxxxxxxxxxxxx141",  buildPassword: "123456", buildUpdateDescription: "2")
end
```

Set a version update description for App:

```
lane :beta do
  gym
  pgyer_upload_v2(api_key: "7f15xxxxxxxxxxxxxxxxxx141", buildUpdateDescription: "update by fastlane")
end
```

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
