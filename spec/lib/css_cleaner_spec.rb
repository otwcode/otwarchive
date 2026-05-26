require "spec_helper"

describe CssCleaner do
  include CssCleaner

  describe ".clean_css_code" do
    context "when cleaning Skin CSS" do
      context "with custom property declaration" do
        it "allows custom property name with lowercase letters" do
          skin = build(:skin, css: ":root { --white: #fff; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --white: #fff;\n}\n\n")
        end

        it "allows custom property name with numbers" do
          skin = build(:skin, css: ":root { --100: 100%; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --100: 100%;\n}\n\n")
        end

        it "allows custom property name with dashes" do
          skin = build(:skin, css: ":root { ---: transparent; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  ---: transparent;\n}\n\n")
        end

        it "allows custom property name with underscores" do
          skin = build(:skin, css: ":root { --__: rgba(255, 255, 255, 0); }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --__: rgba(255, 255, 255, 0);\n}\n\n")
        end

        # https://github.com/premailer/css_parser/blob/2ef7dcaaf9ceaba6652d67a875e4df5e76d8950f/lib/css_parser/rule_set.rb#L228-L232
        it "downcases uppercase letters in custom property name" do
          skin = build(:skin, css: ":root { --RAINBOW: #fff; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --rainbow: #fff;\n}\n\n")
        end

        %w[url URL].each do |function_name|
          it "strips custom property and returns error when value uses #{function_name}() function" do
            skin = build(:skin, css: ":root { --art: #{function_name}(\"https://example.com/img.png\"); }")
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("--art in :root cannot have the value #{function_name}(\"https://example.com/img.png\"), sorry!")
          end
        end

        it "strips custom property and returns error when value uses double quotation marks" do
          skin = build(:skin, css: ":root { --serif: \"Times New Roman\" };")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--serif in :root cannot have the value \"Times New Roman\", sorry!")
        end

        it "strips custom property and returns error when value uses single quotation marks" do
          skin = build(:skin, css: ":root { --sans-serif: 'Lucida Sans' };")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--sans-serif in :root cannot have the value 'Lucida Sans', sorry!")
        end

        it "allows shorthand-style values" do
          skin = build(:skin, css: ":root { --heading: small-caps 1.125rem Georgia, Times New Roman, serif; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq(":root {\n  --heading: small-caps 1.125rem Georgia, Times New Roman, serif;\n}\n\n")
        end

        it "allows var() function as value" do
          skin = build(:skin, css: "#header { --nav_color: var(--brand-color); }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq("#header {\n  --nav_color: var(--brand-color);\n}\n\n")
        end

        it "strips custom property and returns error when shorthand-style value includes url() function" do
          skin = build(:skin, css: ":root { --background: #900 url(\"https://example.com/img.png\"); }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--background in :root cannot have the value #900 url(\"https://example.com/img.png\"), sorry!")
        end

        it "strips custom property and returns error when shorthand-style value includes quotation marks" do
          skin = build(:skin, css: ":root { --heading: small-caps 1.125rem Georgia, \"Times New Roman\", serif; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("--heading in :root cannot have the value small-caps 1.125rem Georgia, \"Times New Roman\", serif, sorry!")
        end

        it "strips custom property with disallowed characters in name and returns error" do
          skin = build(:skin, css: "#footer, #header { --#hash: absolute; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("The --#hash custom property in #footer, #header has an invalid name. Names can contain lowercase letters (a-z) in the English alphabet, numerals zero to nine (0-9), dashes (-), and underscores (_).")
        end

        it "strips invalid property and returns error when property contains text resembling custom property name" do
          skin = build(:skin, css: ":root { color--heading: absolute; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("We don't currently allow the CSS property color--heading -- please notify Support if you think this is an error.")
        end

        # Using a property from SUPPORTED_CSS_SHORTHAND_PROPERTIES allows anything, e.g., font-salmon, awkwardpause, background_witches
        it "allows invalid variation of shorthand property when property contains text resembling custom property name" do
          skin = build(:skin, css: ":root { background--heading: absolute; }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq(":root {\n  background--heading: absolute;\n}\n\n")
        end
      end

      context "with var() function" do
        it "allows simple var() function" do
          skin = build(:skin, css: "div { color: var(--black) }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  color: var(--black);\n}\n\n")
        end

        it "downcases var() function" do
          skin = build(:skin, css: "div { color: VAR(--PURPLE); display: var(--RANDOMThing); height: var(--SHORT); }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  color: var(--purple);\n  display: var(--randomthing);\n  height: var(--short);\n}\n\n")
        end

        %w[var VAR].each do |function_name|
          it "strips #{function_name}() function from content property and returns error" do
            skin = build(:skin, css: "p:before { content: #{function_name}(--text) }")
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("content in p:before cannot have the value #{function_name}(--text), sorry!")
          end

          it "strips #{function_name}() function from font-family property and returns error" do
            skin = build(:skin, css: ".heading { font-family: #{function_name}(--serif) }")
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("font-family in .heading cannot have the value #{function_name}(--serif), sorry!")
          end

          it "strips #{function_name}() function with fallbacks and returns error" do
            skin = build(:skin, css: "p { color: #{function_name}(--blue, #fff) }")
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("color in p cannot have the value #{function_name}(--blue, #fff), sorry!")
          end

          it "strips #{function_name}() function with unclosed parentheses and returns error" do
            skin = build(:skin, css: "p { color: #{function_name}(--blue }")
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("There don't seem to be any rules for p.")
          end
        end

        context "when used in shorthand declaration" do
          it "allows simple var() function" do
            skin = build(:skin, css: "div { font: var(--black) }")
            expect(skin.save).to be_truthy
            expect(skin.css).to eq("div {\n  font: var(--black);\n}\n\n")
          end

          it "allows multiple simple var() functions" do
            skin = build(:skin, css: "blockquote { border: var(--border-width) var(--Border-Style) var(--color) }")
            expect(skin.save).to be_truthy
            expect(skin.css).to eq("blockquote {\n  border: var(--border-width) var(--border-style) var(--color);\n}\n\n")
          end

          it "downcases var() function" do
            skin = build(:skin, css: "div { border: var(--THICK) solid var(--BRIGHTblue); margin: 0 VAR(--wide) }")
            expect(skin.save).to be_truthy
            expect(skin.css).to eq("div {\n  border: var(--thick) solid var(--brightblue);\n  margin: 0 var(--wide);\n}\n\n")
          end
        end
      end

      context "with box-shadow property" do
        it "allows single value" do
          skin = build(:skin, css: "div { box-shadow:inset 1px 1px 2px #000; }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  box-shadow: inset 1px 1px 2px #000;\n}\n\n")
        end

        it "allows multiple values" do
          skin = build(:skin, css: "div { box-shadow: 3px 3px rgba(0, 0, 0, 0.5) inset, -1em 0 0.4em olive }")
          expect(skin.save).to be_truthy
          expect(skin.css).to eq("div {\n  box-shadow: 3px 3px rgba(0, 0, 0, 0.5) inset, -1em 0 0.4em olive;\n}\n\n")
        end
      end

      it "allows !important keyword" do
        skin = build(:skin, css: "div { color: #ddd !important; }")
        expect(skin.save).to be_truthy
        expect(skin.css).to eq("div {\n  color: #ddd !important;\n}\n\n")
      end

      it "strips long invalid property values" do
        skin = build(:skin, css: "div { color: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaah!; }")
        expect(skin.save).to be_falsy
        expect(skin.css).to eq("")
      end
    end

    context "when cleaning WorkSkin CSS" do
      it "strips valid custom properties and returns error" do
        skin = build(:work_skin, css: "#workskin { --background: #fff; }")
        expect(skin.save).to be_falsey
        expect(skin.css).to eq("")
        expect(skin.errors[:base]).to include("Custom properties are not allowed in work skins.")
      end

      context "with var() function as value" do
        {
          "strips var() function and returns error" => "p { color: var(--puce) ; }",
          "strips var() function with uppercase letters in variable and returns error" => "span { border-color:var(--SOMEcolor) }",
          "strips var() function in shorthand value and returns error" => "#id { border: var(--border-width) var(--Border-Style) #000; }",
          "strips VAR() function and returns error" => ".class { width: VAR(--narrow) }",
          "strips VAR() function in shorthand value and returns error" => "p:not(.class) { border: VAR(--border-width) VAR(--Border-Style) #000; }"
        }.each_pair do |description, css|
          it description do
            skin = build(:work_skin, css: css)
            expect(skin.save).to be_falsey
            expect(skin.css).to eq("")
            expect(skin.errors[:base]).to include("The var() function is not allowed in work skins.")
          end
        end
      end

      context "with position property" do
        it "strips value fixed" do
          skin = build(:work_skin, css: "div { position: fixed; }")
          expect(skin.save).to be_falsey
          expect(skin.css).to eq("")
          expect(skin.errors[:base]).to include("The position property in div cannot have the value fixed in work skins, sorry!")
        end

        it "allows other values" do
          skin = build(:work_skin, css: "div { position: absolute; }")
          expect(skin.save).to be_truthy
          expect(skin.reload.css).to eq("#workskin div {\n  position: absolute;\n}\n\n")
        end
      end

      it "prefixes selectors with #workskin" do
        skin = create(:work_skin, css: "p { color: red; }")
        expect(skin.reload.css).to include("#workskin p")
      end
    end
  end
end
