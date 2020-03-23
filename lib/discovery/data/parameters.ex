defmodule Discovery.Data.Parameters do

  defstruct [
    :name,
    :type,
    :description
  ]

  use Accessible
  
end
