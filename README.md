# Poll-And-Diff Publications in Meteor

Suppose you have some non-reactive computation that you want to publish. For example, a complicated query from a graph database (my specific example) or the results of an REST API call to another service. In these cases, the best solution is to "poll and diff". This means recomputing based on some interval and updating the publications with what changed.

## Example 1

The first example will randomly sample 5 of the players every 3 seconds (simulating polling some service), diff the results, and update the publication. You can use the [ddp-analyzer-proxy](https://github.com/arunoda/meteor-ddp-analyzer) to verify that the publication efficiently updates the publication.

## Example 2

Now suppose you are doing some complicated query to create some feed for users. If you are scrolling through a list looking at the results, it can be kind of annoying when the order switches up on you. And expecially on mobile, you would always expect the newest results to come at the bottom, because you've already seen everything on top. This example, purposely does not stop the diff'd results and maintains the order of the results in the list. Using a template variable, we are able to preseve the order of the results until the user leaves the specific view.

## Example 3 ([demo](http://pollanddiff3.meteor.com/))

Now suppose you have multiple services to poll-and-diff and publish to the client, but they act on the same collection. If you publish both to the same collection, the data will be mixed up. However, if you publish to different collections, then you may publish duplicate results. Thus one way to solve this problem is by adding a key to the documents that are published to the client to distinguish which collection they apply to. Luckily, merge-box will efficiently send the minimal amount of information necessary so any duplication between publications will be handled optimally.