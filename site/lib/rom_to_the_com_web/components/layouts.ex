defmodule RomToTheComWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use RomToTheComWeb, :controller` and
  `use RomToTheComWeb, :live_view`.
  """
  use RomToTheComWeb, :html

  embed_templates "layouts/*"

  @description "Find the perfect rom-com by adjusting the romance vs comedy slider. Browse and discover romantic comedy films ranked by their rom-to-com ratio."

  def description, do: @description

  def canonical_url do
    url_config = RomToTheComWeb.Endpoint.config(:url)
    "https://#{url_config[:host]}/"
  end

  def schema_markup do
    JSON.encode!(%{
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => "Rom-to-the-Com",
      "description" => @description
    })
  end
end
