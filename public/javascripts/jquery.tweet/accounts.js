jQuery(function($j){
  $j("#ao3org").tweet({
    username: "ao3org",
    count: 1,
    fetch: 20,
    retweets: false,
    filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
    loading_text: "Loading tweets...",
    join_text: ":",
    template: "{user}{join} {text} {time}"
  }).bind("empty", function() {
    $j(this).append('Follow <a href="http://twitter.com/ao3org">@ao3org</a> for general site news.');
  });
  $j("#ao3_status").tweet({
    username: "ao3_status",
    count: 1,
    fetch: 20,
    retweets: false,
    filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
    loading_text: "Loading tweets...",
    join_text: ":",
    template: "{user}{join} {text} {time}"
  }).bind("empty", function() {
    $j(this).append('Follow <a href="http://twitter.com/AO3_Status">@AO3_Status</a> for site performance updates.');
  });
  $j("#ao3_wranglers").tweet({
    username: "ao3_wranglers",
    count: 1,
    fetch: 20,
    retweets: false,
    filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
    loading_text: "Loading tweets...",
    join_text: ":",
    template: "{user}{join} {text} {time}"
  }).bind("empty", function() {
    $j(this).append('Follow <a href="http://twitter.com/ao3_wranglers">@ao3_wranglers</a> for Tag Wrangling updates.');
  });
  $j("#fanlore_news").tweet({
    username: "fanlore_news",
    count: 1,
    fetch: 20,
    retweets: false,
    filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
    loading_text: "Loading tweets...",
    join_text: ":",
    template: "{user}{join} {text} {time}"
  }).bind("empty", function() {
    $j(this).append('Follow <a href="http://twitter.com/fanlore_news">@fanlore_news</a> for news from the Fanlore wiki.');
  });
  $j("#otw_news").tweet({
    username: "otw_news",
    count: 1,
    fetch: 20,
    retweets: false,
    filter: function(t){ return ! /^@\w+/.test(t.tweet_raw_text); },
    loading_text: "Loading tweets...",
    join_text: ":",
    template: "{user}{join} {text} {time}"
  }).bind("empty", function() {
    $j(this).append('Follow <a href="http://twitter.com/otw_news">@OTW_News</a> for news from The Organization for Transformative Works.');
  });
});