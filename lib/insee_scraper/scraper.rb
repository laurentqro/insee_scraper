require 'pry'
require "kimurai"
require "csv"

class Scraper < Kimurai::Base
  INSEE_URL = "https://www.insee.fr/en/statistiques/serie"
  USER_AGENTS = ["Chrome", "Firefox", "Safari", "Opera"]

  @config = {
    log_level: "debug",
    retry_request_errors: [
      { error: RuntimeError, skip_on_failure: true }
    ],
    user_agent: -> { USER_AGENTS.sample },
    window_size: [1366, 768],
    disable_images: true,
    restart_if: {
      memory_limit: 350_000
    },
    before_request: {
      change_user_agent: true,
      delay: 1..3
    }
  }

  @engine = :selenium_chrome
  @name= 'insee_scraper'

  @start_urls = [
    "#{INSEE_URL}/001710986",
    "#{INSEE_URL}/001710950",
    "#{INSEE_URL}/001710951",
    "#{INSEE_URL}/001710952",
    "#{INSEE_URL}/001710953",
    "#{INSEE_URL}/001710954",
    "#{INSEE_URL}/001710955",
    "#{INSEE_URL}/001710956",
    "#{INSEE_URL}/001710957",
    "#{INSEE_URL}/001710958",
    "#{INSEE_URL}/001710959",
    "#{INSEE_URL}/001710960",
    "#{INSEE_URL}/001710962",
    "#{INSEE_URL}/001710963",
    "#{INSEE_URL}/001710965",
    "#{INSEE_URL}/001710966",
    "#{INSEE_URL}/001710967",
    "#{INSEE_URL}/001710968",
    "#{INSEE_URL}/001710969",
    "#{INSEE_URL}/001710970",
    "#{INSEE_URL}/001710971",
    "#{INSEE_URL}/001710940",
    "#{INSEE_URL}/001710972",
    "#{INSEE_URL}/001710973",
    "#{INSEE_URL}/001710974",
    "#{INSEE_URL}/001710975",
    "#{INSEE_URL}/001710976",
    "#{INSEE_URL}/001710977",
    "#{INSEE_URL}/001710978",
    "#{INSEE_URL}/001710979",
    "#{INSEE_URL}/001710980",
    "#{INSEE_URL}/001710981",
    "#{INSEE_URL}/001710982",
    "#{INSEE_URL}/001710983",
    "#{INSEE_URL}/001710984",
    "#{INSEE_URL}/001710985",
    "#{INSEE_URL}/001711942",
    "#{INSEE_URL}/001711007",
    "#{INSEE_URL}/001710987",
    "#{INSEE_URL}/001710988",
    "#{INSEE_URL}/001710989",
    "#{INSEE_URL}/001710990",
    "#{INSEE_URL}/001710991",
    "#{INSEE_URL}/001710992",
    "#{INSEE_URL}/001710993",
    "#{INSEE_URL}/001710994",
    "#{INSEE_URL}/001710995",
    "#{INSEE_URL}/001710996",
    "#{INSEE_URL}/001710997",
    "#{INSEE_URL}/001710998",
    "#{INSEE_URL}/001710999",
    "#{INSEE_URL}/001711000",
    "#{INSEE_URL}/010605983",
    "#{INSEE_URL}/001711001",
    "#{INSEE_URL}/001711002",
    "#{INSEE_URL}/001711003",
    "#{INSEE_URL}/001711004",
    "#{INSEE_URL}/001796841",
    "#{INSEE_URL}/001711005",
    "#{INSEE_URL}/001711006",
    "#{INSEE_URL}/010607767",
    "#{INSEE_URL}/010607768",
    "#{INSEE_URL}/001711014",
    "#{INSEE_URL}/001711015",
    "#{INSEE_URL}/001711016",
    "#{INSEE_URL}/001711017",
    "#{INSEE_URL}/001711011",
    "#{INSEE_URL}/001711018",
    "#{INSEE_URL}/001711019",
    "#{INSEE_URL}/001711010",
    "#{INSEE_URL}/001711008",
    "#{INSEE_URL}/001711534",
    "#{INSEE_URL}/001711009",
    "#{INSEE_URL}/001711013",
    "#{INSEE_URL}/001711012",
    "#{INSEE_URL}/001711943",
    "#{INSEE_URL}/001738995",
  ]

  @@directory = nil

  def parse(response, url:, data: {})
    create_dir
    scrape_page(response, url)
  end

  def scrape_page(response, url)
    series_table = response.css("table#tableau-series")

    if series_table.empty?
      logger.info "### TABLE EMPTY ! ###"
      logger.info "### REFRESHING BROWSER ###"
      browser.refresh
      sleep 10
      series_table = browser.current_response.css("table#tableau-series")
    end

    series_id = URI.parse(url).path.split("/").last
    series_name = SERIES[series_id]

    file_path = "#{@@directory}/#{series_id}_#{series_name.downcase}.csv"

    series_table_data = series_table.css("tr").map do |row|
      row.css("td").map { |cell| cell.text }
    end

    series_table_data.reject!{ |std| std.empty? }

    series_table_data.map! do |std|
      std[1] = Date::MONTHNAMES.index(std[1])
      std
    end

    save_to_csv(
      file_path,
      series_table_data
    )
  end

  def save_to_csv(file_path, data)
    CSV.open(file_path, "wb") do |csv|
      csv << ["Annee", "Mois", "Valeur", "Date parution au JO"]
      data.each do |line|
        csv << line if !line.empty?
      end
    end
  end

  def create_dir
    d = DateTime.now
    @@directory ||= "#{d.day}-#{d.month}-#{d.year}-#{d.hour}h#{d.minute}m#{d.second}s"
    Dir.mkdir(File.join(Dir.pwd, @@directory)) if !Dir.exist?(@@directory)
  end

  SERIES = {
    "001710986" => "BT01",
    "001710950" => "BT02",
    "001710951" => "BT03",
    "001710952" => "BT06",
    "001710953" => "BT07",
    "001710954" => "BT08",
    "001710955" => "BT09",
    "001710956" => "BT10",
    "001710957" => "BT11",
    "001710958" => "BT12",
    "001710959" => "BT14",
    "001710960" => "BT16b",
    "001710962" => "BT18a",
    "001710963" => "BT19b",
    "001710965" => "BT26",
    "001710966" => "BT27",
    "001710967" => "BT28",
    "001710968" => "BT30",
    "001710969" => "BT32",
    "001710970" => "BT33",
    "001710971" => "BT34",
    "001710940" => "BT35",
    "001710972" => "BT38",
    "001710973" => "BT40",
    "001710974" => "BT41",
    "001710975" => "BT42",
    "001710976" => "BT43",
    "001710977" => "BT45",
    "001710978" => "BT46",
    "001710979" => "BT47",
    "001710980" => "BT48",
    "001710981" => "BT49",
    "001710982" => "BT50",
    "001710983" => "BT51",
    "001710984" => "BT52",
    "001710985" => "BT53",
    "001711942" => "BT54",
    "001711007" => "TP01",
    "001710987" => "TP02",
    "001710988" => "TP03a",
    "001710989" => "TP03b",
    "001710990" => "TP04",
    "001710991" => "TP05a",
    "001710992" => "TP05b",
    "001710993" => "TP06a",
    "001710994" => "TP06b",
    "001710995" => "TP07b",
    "001710996" => "TP08",
    "001710997" => "TP09",
    "001710998" => "TP10a",
    "001710999" => "TP10b",
    "001711000" => "TP10c",
    "010605983" => "TP10d",
    "001711001" => "TP11",
    "001711002" => "TP12a",
    "001711003" => "TP12b",
    "001711004" => "TP12c",
    "001796841" => "TP12d",
    "001711005" => "TP13",
    "001711006" => "TP14",
    "010607767" => "DRR01",
    "010607768" => "DRR02",
    "001711014" => "EV1",
    "001711015" => "EV2",
    "001711016" => "EV3",
    "001711017" => "EV4",
    "001711011" => "FD",
    "001711018" => "FG",
    "001711019" => "FV",
    "001711010" => "ING",
    "001711008" => "MABTGO",
    "001711534" => "MABTSO",
    "001711009" => "MATP",
    "001711013" => "PMR",
    "001711012" => "TRBT",
    "001711943" => "TRTP",
    "001738995" => "TSH"
  }
end
