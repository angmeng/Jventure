class Report < Prawn::Document
    def to_pdf
      self.font_size = 9

      widths = [50, 90, 170, 90, 90, 50]
      headers = ["Date", "Patient Name", "Description", "Charges / Payments", 
             "Patient Portion Due", "Balance"]

      head = make_table([headers], :column_widths => widths)

      data = []

      def row(date, pt, charges, portion_due, balance, widths)
        rows = charges.map { |c| ["", "", c[0], c[1], "", ""] }
        # Date and Patient Name go on the first line.
        rows[0][0] = date
        rows[0][1] = pt
        # Due and Balance go on the last line.
        rows[-1][4] = portion_due
        rows[-1][5] = balance

        # Return a Prawn::Table object to be used as a subtable.
        make_table(rows) do |t|
          t.column_widths = widths
          t.cells.style :borders => [:left, :right], :padding => 2
          t.columns(4..5).align = :right
        end
      end
      
      data << row("1/1/2010", "", [["Balance Forward", ""]], "0.00", "0.00", widths)
      50.times do
        data << row("1/1/2010", "John", [["Foo", "Bar"], ["Foo", "Bar"]], "5.00", "0.00", widths)
      end

      # Wrap head and each data element in an Array -- the outer table has only one
      # column.
      table([[head], *(data.map{|d| [d]})], :header => true, :row_colors => %w[cccccc ffffff]) do
        row(0).style :background_color => '000000', :text_color => 'ffffff'
        cells.style :borders => []
      end
      render
    end
    
    
    def contact  
      headers = %w[Code Email Mobile Bank Birthday]
      data = []
      count = 0
      Agent.all(:order => "code").each do |a|
        count += 1
        data << [a.screen_name, a.email, a.mobile_number, a.bank_status, a.birthday_status]
      end
      text "Total Contact : #{count.to_s}"
      table([headers] + data, :header => true, :row_colors => %w[cccccc ffffff]) do |t|
               t.row(0).style :background_color => '000000', :text_color => 'ffffff'
               t.cells.style :borders => []
      end
      move_down 12
      text "End Of Report"
      render
    end
    
    def agent_list(agents, from, to)
      self.font_size = 9
      headers = %w[Agent Bank\ Account Basic\ Commission Overriding\ Commission Misc Total]
      data = []
      total = 0.0
      agents.each do |a|
        total += a.total
        data << [a.code, a.bank_account, ("%.2f" % a.basic_commission), ("%.2f" % a.sub_commission), ("%.2f" % a.misc_amount), ("%.2f" % a.total)]
      end
      data << ["", "", "", "", "", "Grand Total : #{("%.2f" % total)}"]
      text "List of agents for printing commission " + from.to_s + " - " + to.to_s
      table([headers] + data, :header => true, :row_colors => %w[cccccc ffffff]) do |t|
               t.row(0).style :background_color => '000000', :text_color => 'ffffff'
               t.cells.style :borders => []
               t.columns(2..6).align = :right
      end
      move_down 12
      text "End Of Report"
      render
      
    end

  

end
