/*
  # Add DataForSEO Locations Database

  1. New Tables
    - `locations`
      - `id` (uuid, primary key)
      - `location_code` (integer) - with unique constraint
      - `location_name` (text)
      - `location_code_parent` (integer, nullable)
      - `country_iso_code` (text)
      - `location_type` (text)
      - `available_sources` (text[])
      - `language_name` (text)
      - `language_code` (text)
      - `keywords` (bigint)
      - `serps` (bigint)

  2. Security
    - Enable RLS on `locations` table
    - Add policy for authenticated users to read locations data
*/

-- Create locations table
CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_code integer NOT NULL,
  location_name text NOT NULL,
  location_code_parent integer,
  country_iso_code text,
  location_type text NOT NULL,
  available_sources text[] NOT NULL,
  language_name text NOT NULL,
  language_code text NOT NULL,
  keywords bigint NOT NULL,
  serps bigint NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

-- Create policy for read access
CREATE POLICY "Authenticated users can read locations"
  ON locations
  FOR SELECT
  TO authenticated
  USING (true);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_locations_location_code ON locations(location_code);
CREATE INDEX IF NOT EXISTS idx_locations_country_iso_code ON locations(country_iso_code);
CREATE INDEX IF NOT EXISTS idx_locations_language_code ON locations(language_code);
CREATE INDEX IF NOT EXISTS idx_locations_location_type ON locations(location_type);

-- Add unique constraint for location_code + language_code combination
ALTER TABLE locations ADD CONSTRAINT locations_code_lang_unique UNIQUE (location_code, language_code);

-- Add unique constraint on location_code for self-referencing foreign key
CREATE UNIQUE INDEX idx_locations_unique_code ON locations(location_code) WHERE location_code_parent IS NULL;

-- Add foreign key constraint that references the same table
ALTER TABLE locations ADD CONSTRAINT locations_parent_fk 
  FOREIGN KEY (location_code_parent) 
  REFERENCES locations(location_code);

-- Insert locations data
INSERT INTO locations (
  location_code,
  location_name,
  location_code_parent,
  country_iso_code,
  location_type,
  available_sources,
  language_name,
  language_code,
  keywords,
  serps
) VALUES
  (2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'French', 'fr', 27832115, 1187322),
  (2012, 'Algeria', NULL, 'DZ', 'Country', '{google}', 'Arabic', 'ar', 12886180, 1206870),
  (2024, 'Angola', NULL, 'AO', 'Country', '{google}', 'Portuguese', 'pt', 16242085, 1144131),
  (2031, 'Azerbaijan', NULL, 'AZ', 'Country', '{google}', 'Azeri', 'az', 15485693, 413396),
  (2032, 'Argentina', NULL, 'AR', 'Country', '{google}', 'Spanish', 'es', 60091399, 4252849),
  (2036, 'Australia', NULL, 'AU', 'Country', '{google}', 'English', 'en', 263583314, 17361794),
  (2040, 'Austria', NULL, 'AT', 'Country', '{google}', 'German', 'de', 58517673, 2936579),
  (2048, 'Bahrain', NULL, 'BH', 'Country', '{google}', 'Arabic', 'ar', 12534522, 409986),
  (2050, 'Bangladesh', NULL, 'BD', 'Country', '{google}', 'Bengali', 'bn', 31260281, 1642303),
  (2051, 'Armenia', NULL, 'AM', 'Country', '{google}', 'Armenian', 'hy', 3359135, 207248),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'French', 'fr', 29276243, 287500),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'Dutch', 'nl', 66176031, 3498685),
  (2056, 'Belgium', NULL, 'BE', 'Country', '{google}', 'German', 'de', 20008349, 626300),
  (2068, 'Bolivia', NULL, 'BO', 'Country', '{google}', 'Spanish', 'es', 8608418, 306429),
  (2070, 'Bosnia and Herzegovina', NULL, 'BA', 'Country', '{google}', 'Bosnian', 'bs', 1838793, 668336),
  (2076, 'Brazil', NULL, 'BR', 'Country', '{google}', 'Portuguese', 'pt', 162267403, 15281215),
  (2100, 'Bulgaria', NULL, 'BG', 'Country', '{google}', 'Bulgarian', 'bg', 7872088, 404205),
  (2104, 'Myanmar (Burma)', NULL, 'MM', 'Country', '{google}', 'English', 'en', 15046483, 617956),
  (2116, 'Cambodia', NULL, 'KH', 'Country', '{google}', 'English', 'en', 15324030, 613333),
  (2120, 'Cameroon', NULL, 'CM', 'Country', '{google}', 'French', 'fr', 6979946, 409765),
  (2124, 'Canada', NULL, 'CA', 'Country', '{google}', 'English', 'en', 294488453, 18316825),
  (2124, 'Canada', NULL, 'CA', 'Country', '{google}', 'French', 'fr', 158450671, 8758226),
  (2144, 'Sri Lanka', NULL, 'LK', 'Country', '{google}', 'English', 'en', 16954758, 605615),
  (2152, 'Chile', NULL, 'CL', 'Country', '{google}', 'Spanish', 'es', 44563952, 1856969),
  (2158, 'Taiwan', NULL, 'TW', 'Region', '{google}', 'Chinese (Traditional)', 'zh-TW', 53040951, 4263532),
  (2170, 'Colombia', NULL, 'CO', 'Country', '{google}', 'Spanish', 'es', 54235739, 2110984),
  (2188, 'Costa Rica', NULL, 'CR', 'Country', '{google}', 'Spanish', 'es', 13899115, 495913),
  (2191, 'Croatia', NULL, 'HR', 'Country', '{google}', 'Croatian', 'hr', 7460810, 402657),
  (2196, 'Cyprus', NULL, 'CY', 'Country', '{google}', 'Greek', 'el', 18875177, 298482),
  (2196, 'Cyprus', NULL, 'CY', 'Country', '{google}', 'English', 'en', 15286588, 298429),
  (2203, 'Czechia', NULL, 'CZ', 'Country', '{google}', 'Czech', 'cs', 20375779, 1572773),
  (2208, 'Denmark', NULL, 'DK', 'Country', '{google}', 'Danish', 'da', 29407685, 2445018),
  (2218, 'Ecuador', NULL, 'EC', 'Country', '{google}', 'Spanish', 'es', 20140395, 792131),
  (2222, 'El Salvador', NULL, 'SV', 'Country', '{google}', 'Spanish', 'es', 7694669, 203102),
  (2233, 'Estonia', NULL, 'EE', 'Country', '{google}', 'Estonian', 'et', 3835914, 197923),
  (2246, 'Finland', NULL, 'FI', 'Country', '{google}', 'Finnish', 'fi', 23723729, 1855444),
  (2250, 'France', NULL, 'FR', 'Country', '{google}', 'French', 'fr', 210331247, 19383233),
  (2276, 'Germany', NULL, 'DE', 'Country', '{google}', 'German', 'de', 254266918, 26282667),
  (2288, 'Ghana', NULL, 'GH', 'Country', '{google}', 'English', 'en', 11677141, 701796),
  (2300, 'Greece', NULL, 'GR', 'Country', '{google}', 'Greek', 'el', 21284181, 1498129),
  (2300, 'Greece', NULL, 'GR', 'Country', '{google}', 'English', 'en', 9109492, 604777),
  (2320, 'Guatemala', NULL, 'GT', 'Country', '{google}', 'Spanish', 'es', 13872773, 506256),
  (2344, 'Hong Kong', NULL, 'HK', 'Region', '{google}', 'English', 'en', 29641241, 1204247),
  (2344, 'Hong Kong', NULL, 'HK', 'Region', '{google}', 'Chinese (Traditional)', 'zh-TW', 60975033, 2880562),
  (2348, 'Hungary', NULL, 'HU', 'Country', '{google}', 'Hungarian', 'hu', 15149846, 1055134),
  (2356, 'India', NULL, 'IN', 'Country', '{google}', 'English', 'en', 267108180, 16793913),
  (2356, 'India', NULL, 'IN', 'Country', '{google}', 'Hindi', 'hi', 119098240, 13366343),
  (2360, 'Indonesia', NULL, 'ID', 'Country', '{google}', 'English', 'en', 59760280, 3945710),
  (2360, 'Indonesia', NULL, 'ID', 'Country', '{google}', 'Indonesian', 'id', 97957450, 6933020),
  (2372, 'Ireland', NULL, 'IE', 'Country', '{google}', 'English', 'en', 59352214, 2338092),
  (2376, 'Israel', NULL, 'IL', 'Country', '{google}', 'Hebrew', 'he', 27197709, 1774390),
  (2376, 'Israel', NULL, 'IL', 'Country', '{google}', 'Arabic', 'ar', 15694149, 611909),
  (2380, 'Italy', NULL, 'IT', 'Country', '{google}', 'Italian', 'it', 132535060, 11408770),
  (2384, 'Cote d''Ivoire', NULL, 'CI', 'Country', '{google}', 'French', 'fr', 8888739, 675551),
  (2392, 'Japan', NULL, 'JP', 'Country', '{google}', 'Japanese', 'ja', 262748329, 18741706),
  (2398, 'Kazakhstan', NULL, 'KZ', 'Country', '{google}', 'Russian', 'ru', 16446156, 849626),
  (2400, 'Jordan', NULL, 'JO', 'Country', '{google}', 'Arabic', 'ar', 8729870, 412183),
  (2404, 'Kenya', NULL, 'KE', 'Country', '{google}', 'English', 'en', 24323051, 1216517),
  (2410, 'South Korea', NULL, 'KR', 'Country', '{google}', 'Korean', 'ko', 56740306, 7899897),
  (2428, 'Latvia', NULL, 'LV', 'Country', '{google}', 'Latvian', 'lv', 9808563, 404761),
  (2440, 'Lithuania', NULL, 'LT', 'Country', '{google}', 'Lithuanian', 'lt', 6779224, 597843),
  (2458, 'Malaysia', NULL, 'MY', 'Country', '{google}', 'English', 'en', 45620399, 1803548),
  (2458, 'Malaysia', NULL, 'MY', 'Country', '{google}', 'Malay', 'ms', 40256334, 2424873),
  (2470, 'Malta', NULL, 'MT', 'Country', '{google}', 'English', 'en', 3805185, 102354),
  (2484, 'Mexico', NULL, 'MX', 'Country', '{google}', 'Spanish', 'es', 103587858, 6839690),
  (2498, 'Moldova', NULL, 'MD', 'Country', '{google}', 'Romanian', 'ro', 1444292, 502516),
  (2504, 'Morocco', NULL, 'MA', 'Country', '{google}', 'Arabic', 'ar', 13799787, 1108055),
  (2504, 'Morocco', NULL, 'MA', 'Country', '{google}', 'French', 'fr', 7654153, 634728),
  (2528, 'Netherlands', NULL, 'NL', 'Country', '{google}', 'Dutch', 'nl', 99856501, 7199205),
  (2554, 'New Zealand', NULL, 'NZ', 'Country', '{google}', 'English', 'en', 36662866, 1484154),
  (2558, 'Nicaragua', NULL, 'NI', 'Country', '{google}', 'Spanish', 'es', 4184733, 101651),
  (2566, 'Nigeria', NULL, 'NG', 'Country', '{google}', 'English', 'en', 21488562, 1355718),
  (2578, 'Norway', NULL, 'NO', 'Country', '{google}', 'Norwegian (Bokmål)', 'nb', 31098971, 2754094),
  (2586, 'Pakistan', NULL, 'PK', 'Country', '{google}', 'English', 'en', 45786839, 1280255),
  (2586, 'Pakistan', NULL, 'PK', 'Country', '{google}', 'Urdu', 'ur', 20319129, 300856),
  (2591, 'Panama', NULL, 'PA', 'Country', '{google}', 'Spanish', 'es', 8785648, 612778),
  (2600, 'Paraguay', NULL, 'PY', 'Country', '{google}', 'Spanish', 'es', 7204845, 203786),
  (2604, 'Peru', NULL, 'PE', 'Country', '{google}', 'Spanish', 'es', 38889979, 1492249),
  (2608, 'Philippines', NULL, 'PH', 'Country', '{google}', 'English', 'en', 44310901, 1724637),
  (2608, 'Philippines', NULL, 'PH', 'Country', '{google}', 'Tagalog', 'tl', 38187405, 1824279),
  (2616, 'Poland', NULL, 'PL', 'Country', '{google}', 'Polish', 'pl', 47422230, 3786654),
  (2620, 'Portugal', NULL, 'PT', 'Country', '{google}', 'Portuguese', 'pt', 33326532, 1644589),
  (2642, 'Romania', NULL, 'RO', 'Country', '{google}', 'Romanian', 'ro', 20181636, 1474211),
  (2682, 'Saudi Arabia', NULL, 'SA', 'Country', '{google,amazon}', 'Arabic', 'ar', 44217797, 4869217),
  (2686, 'Senegal', NULL, 'SN', 'Country', '{google}', 'French', 'fr', 5274318, 307421),
  (2688, 'Serbia', NULL, 'RS', 'Country', '{google}', 'Serbian', 'sr', 5982022, 303721),
  (2702, 'Singapore', NULL, 'SG', 'Country', '{google}', 'English', 'en', 66346468, 2314705),
  (2702, 'Singapore', NULL, 'SG', 'Country', '{google}', 'Chinese (Simplified)', 'zh-CN', 28929372, 607072),
  (2703, 'Slovakia', NULL, 'SK', 'Country', '{google}', 'Slovak', 'sk', 10397913, 713120),
  (2704, 'Vietnam', NULL, 'VN', 'Country', '{google}', 'English', 'en', 16843670, 614195),
  (2704, 'Vietnam', NULL, 'VN', 'Country', '{google}', 'Vietnamese', 'vi', 35628651, 1506539),
  (2705, 'Slovenia', NULL, 'SI', 'Country', '{google}', 'Slovenian', 'sl', 6211232, 404558),
  (2710, 'South Africa', NULL, 'ZA', 'Country', '{google}', 'English', 'en', 55309991, 2440948),
  (2724, 'Spain', NULL, 'ES', 'Country', '{google}', 'Spanish', 'es', 163358564, 9662751),
  (2752, 'Sweden', NULL, 'SE', 'Country', '{google}', 'Swedish', 'sv', 38972249, 4020901),
  (2756, 'Switzerland', NULL, 'CH', 'Country', '{google}', 'German', 'de', 78359982, 3390753),
  (2756, 'Switzerland', NULL, 'CH', 'Country', '{google}', 'French', 'fr', 76324902, 1654455),
  (2756, 'Switzerland', NULL, 'CH', 'Country', '{google}', 'Italian', 'it', 12792453, 609460),
  (2764, 'Thailand', NULL, 'TH', 'Country', '{google}', 'Thai', 'th', 42902408, 3275536),
  (2784, 'United Arab Emirates', NULL, 'AE', 'Country', '{google,amazon}', 'Arabic', 'ar', 35005595, 1298696),
  (2784, 'United Arab Emirates', NULL, 'AE', 'Country', '{google}', 'English', 'en', 45795047, 1347698),
  (2788, 'Tunisia', NULL, 'TN', 'Country', '{google}', 'Arabic', 'ar', 9267573, 307604),
  (2792, 'Turkiye', NULL, 'TR', 'Country', '{google}', 'Turkish', 'tr', 50036806, 5905736),
  (2804, 'Ukraine', NULL, 'UA', 'Country', '{google}', 'Ukrainian', 'uk', 132640758, 11247222),
  (2804, 'Ukraine', NULL, 'UA', 'Country', '{google}', 'Russian', 'ru', 112563923, 5695329),
  (2807, 'North Macedonia', NULL, 'MK', 'Country', '{google}', 'Macedonian', 'mk', 9435119, 206427),
  (2818, 'Egypt', NULL, 'EG', 'Country', '{google,amazon}', 'Arabic', 'ar', 32734890, 2339237),
  (2818, 'Egypt', NULL, 'EG', 'Country', '{google}', 'English', 'en', 21136881, 1241584),
  (2826, 'United Kingdom', NULL, 'GB', 'Country', '{google}', 'English', 'en', 431463891, 36239799),
  (2840, 'United States', NULL, 'US', 'Country', '{google,bing,amazon}', 'English', 'en', 1122464691, 199887763),
  (2840, 'United States', NULL, 'US', 'Country', '{google}', 'Spanish', 'es', 146539017, 6606085),
  (2854, 'Burkina Faso', NULL, 'BF', 'Country', '{google}', 'French', 'fr', 5056537, 318779),
  (2858, 'Uruguay', NULL, 'UY', 'Country', '{google}', 'Spanish', 'es', 12583569, 406992),
  (2862, 'Venezuela', NULL, 'VE', 'Country', '{google}', 'Spanish', 'es', 45539884, 2222424);