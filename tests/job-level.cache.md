Find the last run of any successful workflow instrumented with the latest version of the job-level instrumentation.
Select one that is not a locally checked out version of the action, one that is successful, and one that has at least one preceding workflow it depends on that has been instrumented by the same version as well.
Then verify that the cache was warm when installing the action in the pre step. Compare to the code to search for indicators.
