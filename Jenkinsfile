pipeline {

  agent {
      docker {
          image 'steevaavoo/psjenkinsagent:latest'
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
      }
  }

  environment {
    FAVOURITE_FRUIT = 'tomato'
  }

  stages {

    stage('set a var') {
      steps {
        // This prints out all environment variables, sorted alphabetically
        sh 'printenv | sort'

        script {
            // This will set a global variable which may be shared across stages
            TUBE_STATUS = 'delayed'
            // This will set an environment variable
            env.YESTERDAYS_WEATHER = 'foggy'

            env.ENV_BRANCH = 'demo-branch'

            DEMO_BRANCH = 'demo2-branch'
        }
      }
    }

    stage('read a var') {
      steps {
          // This prints out all environment variables, sorted alphabetically
          // The env var YESTERDAYS_WEATHER will appear in this list,
          // but the variable TUBE_STATUS will not.
          sh 'printenv | sort'

          // This will print 'The tube is currently '
          // because single-quotes causes the expression to be evaluated
          // by bash (NOT Jenkins); and the shell doesn't know the value of
          // TUBE_STATUS, because it wasn never set as an environment variable.
          sh 'echo The tube is currently ${TUBE_STATUS}'

          // And now with double-quotes, this will print:
          // 'The tube is currently delayed'
          // This is because the variable TUBE_STATUS is expanded by Jenkins
          sh "echo The tube is currently ${TUBE_STATUS}"

          // This will print: Yesterdays weather was foggy
          // because the shell is aware of the env var YESTERDAYS_WEATHER
          sh 'echo Yesterdays weather was ${YESTERDAYS_WEATHER}'

      }
    }

  } // stages
}
