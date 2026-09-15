function events(previous, current) {
  var before = {}
  previous.forEach(function(agent) { before[String(agent.pane_id)] = agent })
  return current.filter(function(agent) {
    var old = before[String(agent.pane_id)]
    if (!old || old.terminal_id !== agent.terminal_id) return false
    return (agent.agent_status === "blocked" && old.agent_status !== "blocked")
      || (old.agent_status === "working" && (agent.agent_status === "idle" || agent.agent_status === "done"))
  })
}
