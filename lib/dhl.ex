defmodule DHL do
  def request(piece_code) do
    %Req.Response{
      status: 200,
      body: body
    } =
      Req.new(
        method: :get,
        base_url: "https://www.dhl.de",
        url: "/int-verfolgen/data/search",
        params: [
          {"piececode", piece_code},
          {"language", "de"}
        ],
        headers: %{
          referer:
            "Referer: https://www.dhl.de/de/privatkunden/pakete-empfangen/verfolgen.html?lang=de&idc=#{piece_code}"
        }
      )
      |> Req.request!()

    %{
      "isRateLimited" => _is_rate_limited,
      "mergedAnonymousShipmentListIds" => _merged_anonymous_shipment_list_ids,
      "sendungen" => [
        %{
          "hasCompleteDetails" => _has_complete_details,
          "id" => _id,
          "sendungsdetails" => %{
            "bahnpaket" => _train_package,
            "expressSendung" => _express_shipment,
            "international" => _international,
            "isShipperPlz" => _is_shipper_postal_code,
            "istZugestellt" => _is_delivered,
            "mehrInformationenVerfuegbar" => _more_information_available,
            "quelle" => _source,
            "retoure" => _return,
            "ruecksendung" => _return_shipment,
            "sendungsnummern" => %{"sendungsnummer" => _shipment_number},
            "sendungsverlauf" => %{
              "datumAktuellerStatus" => current_status_date,
              "events" => events,
              "aktuellerStatus" => current_status,
              "kurzStatus" => short_status,
              "maximalFortschritt" => _maximaler_fortschritt
            },
            "services" => %{
              "statusbenachrichtigung" => %{"authenticationRequired" => _authentication_required}
            },
            "showDigitalNotificationCtaHint" => _show_digital_notification_cta_hint,
            "showQualityLevelHint" => _show_quality_level_hint,
            "twoManHandling" => _two_man_handling,
            "unplausibel" => _implausible,
            "warenpost" => _goods_post,
            "zielland" => _destination_country,
            "zustellung" => %{
              "abholcodeAvailable" => _pickup_code_available,
              "benachrichtigtInFiliale" => _notified_in_branch,
              "empfaenger" => _recipient,
              "zugestelltAnEmpfaenger" => _delivered_to_recipient
            }
          },
          "sendungsinfo" => %{
            "gesuchteSendungsnummer" => _searched_shipment_number,
            "sendungsrichtung" => _shipment_direction
          },
          "versandDatumBenoetigt" => _shipping_date_required
        }
      ]
    } = body

    %{
      piece_code: piece_code,
      short_status: short_status,
      current_status_date: current_status_date,
      current_status: current_status,
      events: events
    }
  end

  defp md_row(%{"datum" => date, "status" => status}) do
    {:ok, parsed_date, _offset} = DateTime.from_iso8601(date)
    diff = DateTime.diff(DateTime.utc_now(), parsed_date, :hour)
    "| #{diff} hours ago | #{status} |"
  end

  def kino(piece_code) do
    result = DHL.request(piece_code)
    """
    # Shipment #{result.piece_code}
    Check it online [here](https://www.dhl.de/de/privatkunden/pakete-empfangen/verfolgen.html?lang=de&idc=#{piece_code})
    ## Status
    #{result.short_status}
    ## Details (#{result.current_status_date})
    #{result.current_status}
    ## History
    | Date | Event |
    | --- | --- |
    #{result.events |> Enum.map(&md_row/1) |> Enum.reverse() |> Enum.join("\n")}
    """
    |> Kino.Markdown.new()
  end
end

#DHL.kino(Kino.Input.read(sendungs_nummer_input))
