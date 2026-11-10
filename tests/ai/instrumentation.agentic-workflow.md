Find the last run of any agentic workflow (indicated by a lock.yml) instrumented with the latest version of the job-level instrumentation.
First, check that the workflow that it didn't fail.
Second, download the logs. Find the log mentioning the trace and span id and find and query all spans from any connected trace storage backend.

Consider this test failed if any is true:
*) the workflow failed or timed out
*) any spans except the root span is orphaned (having a parent that is unavailable)
*) there is at least one span with gen_ai attributes in every step doing ai-based work.
