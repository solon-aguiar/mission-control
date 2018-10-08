# Mission Control
## Version of Ruby & dependencies
I used ruby `2.3.3` while developing. While it should work for earlier versions, I have not tested it myself.

The only dependency I added was on `rspec` so that I could run the unit tests. To make sure the code followed the standard I also used `rubocop`, but I removed it before submitting.

## Running the tests
To run all the unit tests:

```sh
$ bundle install
$ bundle exec rspec
```

There is a test called `game_spec.rb`. This is a mix of smoke and unit test. It mocks all the parts that would make the tests non-deterministic (such as the `ChaosMonkey` and the engine speed) and tests some of the important game scenarios.

## Running the application
I created a script in `/bin`. To start the application:

```sh
$ bundle install
$ ruby -Ilib ./bin/mission-control
```

## Assumptions & Comments
I made minor tweaks compared to the sample session output. They are based on my understanding of the requirements listed on the repo. Some thoughts:

1. Once a flight explodes, it cannot be retried (it wasn't very clear from the instructions if this was the case, but it looked like from the description).
2. At the end of the session, the summary for all missions combined is displayed.
3. After each mission, the summary just for that mission is displayed.
4. I made the rocket actually have varrying speeds. It takes around 4 sec for it to reach estabilization speed (the average given). In those first 4 seconds it gains speed quadractically as a function of the time. After that, the speed follows a gaussian distribution with the specified average (1,500 km/h) and 100 km/h standard deviation.
5. The fuel burn rate is a function of the speed (which, as said above, is a function of time). Based on the averages it is a simple operation to calculate the burn rate at any given point.
6. I hardcoded the text justification in the output of the mission plan for the purposes of this test. Ideally I'd calculate that on each run to handle the case the default values changed.
7. The mission status is printed on the screen every 30 seconds.

--
Thank you for reading!