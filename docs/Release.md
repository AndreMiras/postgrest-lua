# How to release

This is documenting the release process.

We're also using [semantic versioning](https://semver.org/) where `major.minor.patch` should be set accordingly.

```sh
VERSION=major.minor.patch make release
```

This target will perform the following actions:

- create a new rockspec and update it to match the new release version
- commit and tag
- push the changes and tag

Then the GitHub Action workflow will publish automatically to LuaRocks.

Then click the new tag and generate/pin the latest release:
https://github.com/AndreMiras/postgrest-lua/tags
