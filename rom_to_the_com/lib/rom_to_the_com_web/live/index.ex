defmodule RomToTheComWeb.Live.Index do
  use RomToTheComWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-black-100 flex flex-col min-h-screen">
      <div class="flex-grow">
        <div class="max-w-2xl mx-auto p-6 mt-10">
          <h1 class="text-3xl font-bold text-center mb-6">Rom-to-the-Com</h1>

          <div class="mb-8">
            <div class="flex justify-between mb-2">
              <span class="text-sm">99% Romantic</span>
              <span class="text-sm">99% Comedy</span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value="50"
              step="5"
              class="w-full"
              id="rom-com-slider"
            />
            <div class="text-center mt-2" id="slider-value">
              50%/50% (±5)
            </div>
          </div>

          <table class="w-full mb-8">
            <thead>
              <tr>
                <th class="text-left">Title</th>
                <th class="text-left">Year</th>
                <th class="text-left">Rank</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Notting Hill</td>
                <td>1999</td>
                <td>70%/30%</td>
              </tr>
              <tr>
                <td>10 Things I Hate About You</td>
                <td>1999</td>
                <td>55%/45%</td>
              </tr>
              <tr>
                <td>No Hard Feelings</td>
                <td>2023</td>
                <td>45%/55%</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <footer class="mt-auto">
        <div class="max-w-2xl mx-auto p-6 mb-10">
          <hr class="mb-6 border-black" />
          <div class="text-sm text-black-600">
            <h2 class="font-semibold mb-1">Colophon</h2>
            <p>The idea for this came about during a roadtrip with some friends.</p>
          </div>
        </div>
      </footer>
    </div>
    """
  end
end
