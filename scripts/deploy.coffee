_ = require 'lodash'

module.exports = (robot) ->
  robot.hear /hi/i, (res) ->
    res.send "Hi human !"

  robot.respond /show projects/, (hures) ->
    projectsUrl = "https://codeship.com/api/v1/projects.json?api_key=#{process.env.CODESHIP_API_KEY}"
    robot.http(projectsUrl)
      .get() (err, res, body) ->
        if err
          hures.send "Encountered an error : #{err}"
        parsedBody = JSON.parse body
        projectsStrings = parsedBody.projects.map((project) ->
            project.id + ' ' + project.repository_name
        )
        hures.send projectsStrings.join ', '

  robot.respond /show builds for (0|[1-9][0-9]*)/, (hures) ->
    projectId = hures.match[1]
    if !projectId
      hures.send "You need to give me a valid build id"
      return
    buildUrl = "https://codeship.com/api/v1/projects/#{projectId}.json?api_key=#{process.env.CODESHIP_API_KEY}"

    robot.http(buildUrl)
      .get() (err, res, body) ->
        if err
          hures.send "Encountered an error : #{err}"
          return
        parsedBody = JSON.parse body
        console.log parsedBody
        buildsStrings = parsedBody.builds.map((build) ->
            build.id + ' ' + build.status + ' ' + build.branch
        )
        hures.send buildsStrings.join ', '

    robot.respond /rebuild (0|[1-9][0-9]*)/, (hures) ->
      buildId = hures.match[1]
      buildUrl = "https://codeship.com/api/v1/builds/#{buildId}/restart.json?api_key=#{process.env.CODESHIP_API_KEY}"
      robot.http(buildUrl)
        .header('Content-Type', 'application/json')
        .post() (err, res, body) ->
          if err
            hures.send "Encountered an error: #{err}"
          hures.send "Rebuilding app"
