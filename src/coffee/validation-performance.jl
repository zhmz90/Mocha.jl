export ValidationPerformance
export register

type ValidationPerformance <: Coffee
  validation_net :: Net

  # listeners will be notified each time we compute
  # performance on the validation set
  listeners :: Vector{Function}
end

# Listener should be a function that takes the coffee lounge, the
# net and solver state as parameters. The listener can query the coffee lounge
# for any updated statistics.
function register(coffee::ValidationPerformance, listener::Function)
  push!(coffee.listeners, listener)
end

function init(coffee::ValidationPerformance, ::Net)
  init(coffee.validation_net)
end
function enjoy(lounge::CoffeeLounge, coffee::ValidationPerformance, net::Net, state::SolverState)
  epoch = get_epoch(coffee.validation_net)
  while true
    forward(coffee.validation_net)
    if get_epoch(coffee.validation_net) > epoch
      break
    end
  end

  @info("")
  @info("## Performance on Validation Set after $(state.iter) iterations")
  @info("---------------------------------------------------------")
  dump_statistics(lounge, coffee.validation_net, show=true)
  @info("---------------------------------------------------------")
  @info("")

  reset_statistics(coffee.validation_net)

  # notify listeners
  for listener in coffee.listeners
    listener(lounge, net, state)
  end
end
function destroy(coffee::ValidationPerformance, ::Net)
  # We don't destroy here as we didn't construct the network
  # Let the user destroy the network when they are done.
  # destroy(coffee.validation_net)
end
