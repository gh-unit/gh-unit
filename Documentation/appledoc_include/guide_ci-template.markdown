## Using Jenkins with GHUnit

Jenkins (http://jenkins-ci.org/) is a continuous integration server that has a broad set of support and plugins, and is easy to set up. You can use Jenkins to run your GHUnit tests after every checkin, and report the results to your development group in a variety of ways (by email, to Campfire, and so on).

Here's how to set up Jenkins with GHUnit.

- Follow the instructions to set up a Makefile for your GHUnit project.

- Download `jenkins.war` from http://jenkins-ci.org/. Run it with `java -jar jenkins.war`. It will start up on http://localhost:8080/

- Go to `Manage Jenkins -> Manage Plugins` and install whatever plugins you need for your project.  For instance, you might want to install the Git and GitHub plugins if you host your code on GitHub (http://www.github.com)

- Create a new job for your project and click on `Configure`. Most of the options are self-explanatory or can be figured out with the online help. You probably
want to configure `Source Code Management`, and then under `Build Triggers` check `Poll SCM` and add a schedule of `* * * * *` (which checks your source control system for new changes once a minute).

- Under `Build`, enter the following command:

        make clean && WRITE_JUNIT_XML=YES JUNIT_XML_DIR=tmp/test-results make test


- Under `Post-build Actions`, check `Publish JUnit test result report` and enter the following in `Test report XMLs`:

        tmp/test-results/*.xml


That's all it takes. Check in a change that breaks one of your tests. Hudson should detect the change, run a build and test, and then report the failure. Fix the test, check in again, and you should see a successful build report.

## Troubleshooting

If your Xcode build fails with a set of font-related errors, you may be running Hudson headless (e.g., via an SSH session). Launch Hudson via Terminal.app on the build machine (or otherwise attach a DISPLAY to the session) in order to address this.