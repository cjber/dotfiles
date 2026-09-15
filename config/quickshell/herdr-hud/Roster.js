// Keep the original roster order inside each priority group.
function priority(agent, unread) {
  var status = String(agent.agent_status || "")
  if (status === "blocked") return 0
  if (status === "working") return 1
  return unread[String(agent.pane_id || "")] ? 0 : 2
}

function sorted(agents, unread) {
  return agents.map(function(agent, index) {
    return { agent: agent, index: index, priority: priority(agent, unread) }
  }).sort(function(a, b) {
    return a.priority - b.priority || a.index - b.index
  }).map(function(item) { return item.agent })
}
