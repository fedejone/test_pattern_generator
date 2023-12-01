
module test_pattern_generator_ciris #(parameter DATA_WIDTH    = 24) (
  input                         clk_i           , // Clock
  input                         rst_i           , // Asynchronous reset active low
  input                         ready_i         , // сигнал готовности следующего модуля
  input                         enable          ,
  input                         mode_bw_i       , // выбор цвет или чб
  input        [          31:0] height_i        , // высота
  input        [          31:0] width_i         , // ширина
  input        [           5:0] interlaced_i    , // развертка
  input        [           7:0] offset_frames_i , // кадр после которого будет сдвиг
  input        [          23:0] color_onecolor_i, // цвет монохрома
  ///
  output                        valid_o         ,
  output logic                  end_of_video_o  ,
  output logic [DATA_WIDTH-1:0] data_stndrt_o   , // стандартные полосы
  output logic [DATA_WIDTH-1:0] data_offset_o   , // полосы со свдигом
  output logic [DATA_WIDTH-1:0] data_grad_o     , // градиент
  output logic [DATA_WIDTH-1:0] data_onecolor_o , // один цвет
  output logic [DATA_WIDTH-1:0] data_imag_o     , // картинка
  output logic [           3:0] interlaced_o    , // разветрка
  output logic                  vip_ctrl_send_o   // послать контольный пакет
);
/// внутренние сигналы
  logic [          13:0] cnt_line           ; // счетчик полос
  logic [          13:0] cnt_stripe         ; // счетчик пикселей в полосе
  logic [           5:0] cnt_offset         ; // счетчик кадров для сдвига
  logic [DATA_WIDTH-1:0] offset_data   [7:0]; // данные для сдвига
  logic [           1:0] grad_reg_color     ;
  logic                  grad_reg_bw        ;
  logic [          15:0] width_reg          ; // регистр состояния разрешения
  logic [          15:0] heght_reg          ; // регистр состояния разрешения
// сигналы цветов
  logic [DATA_WIDTH-1:0] data_reg_stndrt    ;
  logic [DATA_WIDTH-1:0] data_reg_offset    ;
  logic [DATA_WIDTH-1:0] data_reg_grad      ;
  logic [DATA_WIDTH-1:0] data_reg_grad_bw   ;
  logic [DATA_WIDTH-1:0] data_reg_grad_color;
  logic [DATA_WIDTH-1:0] data_reg_onecolor  ;
  logic [DATA_WIDTH-1:0] data_reg_image     ;
//коэффициенты для выбора цвета
  wire coef_c;
  wire coef_b;
  wire coef_a;

  enum logic [2:0] {IDLE, START_CNTRL, DATA, END_DATA} color_states; // состояния автомата

/*------------------------------------------------------------------------------
--  автомат вывода всех сигналов кроме data и формирования трех счетчиков
------------------------------------------------------------------------------*/

  always_ff @( posedge clk_i or negedge rst_i ) begin
    if( ~rst_i ) begin
      width_reg       <= '0;
      heght_reg       <= '0;
      interlaced_o    <= '0;
      end_of_video_o  <= '0;
      vip_ctrl_send_o <= '0;
      data_stndrt_o   <= '0;
      data_offset_o   <= '0;
      data_grad_o     <= '0;
      data_onecolor_o <= '0;
      data_imag_o     <= '0;
      cnt_stripe      <= '0;
      cnt_line        <= '0;
      color_states    <= IDLE;
    end else if ( enable ) begin
      width_reg    <= width_i;
      heght_reg    <= height_i;
      interlaced_o <= interlaced_i;
      case (color_states)
        IDLE :
          begin
            vip_ctrl_send_o <= '1;
            data_stndrt_o   <= data_reg_stndrt;
            data_offset_o   <= data_reg_offset;
            data_grad_o     <= data_reg_grad;
            data_onecolor_o <= data_reg_onecolor;
            data_imag_o     <= data_reg_image;
            end_of_video_o  <= '0;
            cnt_stripe      <= '0;
            cnt_line        <= '0;
            color_states    <= DATA;
          end
        DATA :
          begin
            vip_ctrl_send_o <= '0;
            if ( (width_i !== width_reg) || (height_i !== heght_reg) ) begin // после смены разрешения автомат сбрасывается
                color_states <= IDLE;
              end
            if ( ready_i ) begin
              data_stndrt_o   <= data_reg_stndrt;
              data_offset_o   <= data_reg_offset;
              data_grad_o     <= data_reg_grad;
              data_onecolor_o <= data_reg_onecolor;
              data_imag_o     <= data_reg_image;
              if ( cnt_stripe != width_i  )
                cnt_stripe <= cnt_stripe + 1'b1;
              else
                cnt_stripe <= 'd1;
              if ( cnt_stripe == width_i - 1 )
                cnt_line <= cnt_line + 1'b1;
              if ( cnt_stripe == width_i - 1 && cnt_line == height_i - 1 ) begin
                end_of_video_o <= '0;
                color_states   <= END_DATA;
              end
            end
            else begin
              data_stndrt_o   <= data_reg_stndrt;
              data_offset_o   <= data_reg_offset;
              data_grad_o     <= data_reg_grad;
              data_onecolor_o <= data_reg_onecolor;
              data_imag_o     <= data_reg_image;
            end
          end
        END_DATA :
          begin
            if ( ready_i ) begin
              data_stndrt_o   <= data_reg_stndrt;
              data_offset_o   <= data_reg_offset;
              data_grad_o     <= data_reg_grad;
              data_imag_o     <= data_reg_image;
              data_onecolor_o <= data_reg_onecolor;
              end_of_video_o  <= '1;
              cnt_stripe      <= cnt_stripe + 1'b1;
              color_states    <= IDLE;
            end else begin
              data_stndrt_o   <= data_reg_stndrt;
              data_offset_o   <= data_reg_offset;
              data_grad_o     <= data_reg_grad;
              data_onecolor_o <= data_reg_onecolor;
              data_imag_o     <= data_reg_image;
              end_of_video_o  <= '0;
            end
          end
        default :
          begin
            data_stndrt_o   <= data_reg_stndrt;
            data_offset_o   <= data_reg_offset;
            data_grad_o     <= data_reg_grad;
            data_onecolor_o <= data_reg_onecolor;
            data_imag_o     <= data_reg_image;
            vip_ctrl_send_o <= '0;
            end_of_video_o  <= '0;
          end
      endcase
    end
  end

/*------------------------------------------------------------------------------
--  счетчик кадров
------------------------------------------------------------------------------*/

  always_ff @( posedge clk_i or negedge rst_i ) begin : proc_cnt_offset
    if( ~rst_i ) begin
      cnt_offset <= '0;
    end else if ( ~enable ) begin
      cnt_offset <= '0;
    end else if ( cnt_offset == offset_frames_i && ready_i ) begin
      cnt_offset <= '0;
    end else if ((cnt_stripe == width_i - 1) && (cnt_line == height_i - 1)) begin
      cnt_offset <= cnt_offset + 1'b1;
    end
  end

/*------------------------------------------------------------------------------
--  управление цветным градиентом
------------------------------------------------------------------------------*/

  always_ff @(posedge clk_i or negedge rst_i) begin : proc_grad_reg
    if( ~rst_i ) begin
      grad_reg_color <= '0;
    end else if (( cnt_stripe == 1 || cnt_stripe == 1022 || cnt_stripe == 2047 ||  cnt_stripe == 3071 || cnt_stripe == 4095 || cnt_stripe == 5119) && ready_i) begin
      grad_reg_color <= '0;
    end else if ((data_reg_grad_color == 66047 || data_reg_grad_color == 65025 || data_reg_grad_color == 16646400) && ready_i ) begin
      grad_reg_color <= grad_reg_color + 1'b1 ;
    end
  end

/*------------------------------------------------------------------------------
--  управление чб градиентом
------------------------------------------------------------------------------*/
  
  always_ff @(posedge clk_i or negedge rst_i) begin : proc_grad_reg_bw
    if( ~rst_i  ) begin
      grad_reg_bw <= '0;
    end else if (cnt_stripe == 1023) begin
      grad_reg_bw <= '0;
    end else if ( data_reg_grad_bw == 3684408 ) begin
      grad_reg_bw <= '1;
    end else begin
      grad_reg_bw <= '0;
    end
  end

/*------------------------------------------------------------------------------
--  коэффициенты
------------------------------------------------------------------------------*/

  assign coef_c = cnt_stripe [7];
  assign coef_b = cnt_stripe [8];
  assign coef_a = cnt_stripe [9];

/*------------------------------------------------------------------------------
--  полосы со свдигом
------------------------------------------------------------------------------*/
  always_ff @(posedge clk_i or negedge rst_i) begin : proc_offset_data
    if( ~rst_i ) begin
      if ((~mode_bw_i) || ~enable) begin
        offset_data[0] <= 'hFFFFFF;     // белый
        offset_data[1] <= 'h00FFFF;     // желтый
        offset_data[2] <= 'hFFFF00;     // голубой
        offset_data[3] <= 'h00FF00;     // зеленый
        offset_data[4] <= 'hFF00FF;     // розовый
        offset_data[5] <= 'h0000FF;     // красный
        offset_data[6] <= 'hFF0000;     // синий
        offset_data[7] <= 'h000000;     // черный
      end else if ((mode_bw_i) || ~enable) begin
        offset_data[0] <= 'hFFFFFF;
        offset_data[1] <= 'hD1D1D1;
        offset_data[2] <= 'hC7C7C7;
        offset_data[3] <= 'hB2AEBE;
        offset_data[4] <= 'h858585;
        offset_data[5] <= 'h666666;
        offset_data[6] <= 'h212121;
        offset_data[7] <= 'h000000;
      end
    end else if ( cnt_offset == offset_frames_i && ready_i ) begin
      offset_data[7] <= offset_data[6];
      offset_data[6] <= offset_data[1];
      offset_data[5] <= offset_data[4];
      offset_data[4] <= offset_data[7];
      offset_data[3] <= offset_data[2];
      offset_data[2] <= offset_data[5];
      offset_data[1] <= offset_data[0];
      offset_data[0] <= offset_data[3];
    end
  end

  assign data_reg_offset = coef_a ?
    (coef_b  ?
      (coef_c ? offset_data [1] : offset_data [0]):
      (coef_c ? offset_data [3] : offset_data [2]))
    :
    (coef_b  ?
      (coef_c ? offset_data [5] : offset_data [4] ):
      (coef_c ? offset_data [7] : offset_data [6]));

/*------------------------------------------------------------------------------
--  стандартные полосы
------------------------------------------------------------------------------*/

  assign data_reg_stndrt = (~mode_bw_i) ? coef_a ?
    (coef_b  ?
      (coef_c ? 'hFFFFFF : 'hFFFF00 ):
      (coef_c ? 'h00FFFF : 'hFF00FF))
    :
    (coef_b  ?
      (coef_c ? 'h0000FF : 'h00FF00 ):
      (coef_c ? 'hFF0000 : 'h000000))
    :
    (coef_a ?         (coef_b ?
        (coef_c ? 'hFFFFFF : 'hD1D1D1 ):
        (coef_c ? 'hC7C7C7 : 'hB2AEBE))
      :  (coef_b  ?
        (coef_c ? 'h858585 : 'h666666 ):
        (coef_c ? 'h2E2E2E : 'h000000)));

/*------------------------------------------------------------------------------
--  градиент цветной
------------------ ------------------------------------------------------------*/

  always_ff @( posedge clk_i or negedge rst_i ) begin : proc_data_grad
    if( ~rst_i  ) begin
      data_reg_grad_color <= 'hFFFFFF;
    end else if (( cnt_stripe == 1 || cnt_stripe == 1022 ||  cnt_stripe == 2047 ||  cnt_stripe == 3071 || cnt_stripe == 4095 || cnt_stripe == 5119) && ready_i) begin
      data_reg_grad_color <= 'hFFFFFF;
    end else begin
      if ( ready_i && grad_reg_color == 0)
        data_reg_grad_color <= data_reg_grad_color - 65792;
      else if ( ready_i && grad_reg_color == 1) begin
        data_reg_grad_color[14:0] <= data_reg_grad_color[14:0] - 1;
        data_reg_grad_color[15:8] <= data_reg_grad_color[15:8] + 1;
      end else if ( ready_i && grad_reg_color == 2) begin
        data_reg_grad_color[15:8]  <= data_reg_grad_color[15:8] - 1;
        data_reg_grad_color[23:16] <= data_reg_grad_color[23:16] + 1;
      end else if (ready_i && grad_reg_color == 3) begin
        data_reg_grad_color <= data_reg_grad_color + 1;
      end
    end
  end

  assign data_reg_grad = (~mode_bw_i) ? data_reg_grad_color : data_reg_grad_bw; // выбор цветности градиента 

/*------------------------------------------------------------------------------
--  градиент ЧБ
------------------------------------------------------------------------------*/
  
  always_ff @( posedge clk_i or negedge rst_i ) begin
    if( ~rst_i ) begin
      data_reg_grad_bw <= 'hFFFFFF;
    end else if ((cnt_stripe == 1023 || cnt_stripe == 2047 || cnt_stripe == 3071 || cnt_stripe == 1) && ready_i && ~vip_ctrl_send_o) begin
      data_reg_grad_bw <= 'hFFFFFF;
    end else if ( grad_reg_bw ) begin
      data_reg_grad_bw <= 'hFFFFFF;
    end else begin
      if ( ready_i )
        data_reg_grad_bw <= data_reg_grad_bw - 65793;
    end
  end

/*------------------------------------------------------------------------------
--  один цвет
------------------------------------------------------------------------------*/

  assign data_reg_onecolor = color_onecolor_i;

  /*------------------------------------------------------------------------------
  --  картинка (шахматы)
  ------------------------------------------------------------------------------*/

  always_ff @( posedge clk_i or negedge rst_i ) begin
    if( ~rst_i  ) begin
      data_reg_image <= 'h000000;
    end else
    if (((cnt_line > (height_i/10) && cnt_line <= ((height_i/10)*2)) || (cnt_line > ((height_i/10)*3) && cnt_line <= ((height_i/10)*4)) || (cnt_line > ((height_i/10)*5) && cnt_line <= ((height_i/10)*6)) || (cnt_line > ((height_i/10)*7) && cnt_line <= ((height_i/10)*8)) || (cnt_line >= ((height_i/10)*9))) && ready_i ) begin
      if ((cnt_stripe == (width_i/10)  || cnt_stripe == ((width_i/10)*3) || cnt_stripe == ((width_i/10)*5) || cnt_stripe == ((width_i/10)*7) || cnt_stripe == ((width_i/10)*9)) && ready_i )
        data_reg_image <= 'h000000;
      else if ((cnt_stripe == ((width_i/10)*2)  || cnt_stripe == ((width_i/10)*4 ) || cnt_stripe == ((width_i/10)*6 ) || cnt_stripe == ((width_i/10)*8 ) || cnt_stripe == ((width_i/10)*10)) && ready_i )
        data_reg_image <= 'hFFFFFF;
    end else begin
      if (( cnt_stripe == 2 || cnt_stripe == ((width_i/10)*2 )  || cnt_stripe == ((width_i/10)*4) || cnt_stripe == ((width_i/10)*6) || cnt_stripe == ((width_i/10)*8) || cnt_stripe == ((width_i/10)*10)-1) && ready_i )
        data_reg_image <= 'h000000;
      else if (( cnt_stripe == (width_i/10) || cnt_stripe == ((width_i/10)*3 ) || cnt_stripe == ((width_i/10)*5 ) || cnt_stripe == ((width_i/10)*7 ) || cnt_stripe == ((width_i/10)*9 )) && ready_i )
        data_reg_image <= 'hFFFFFF;
    end
  end

///

  assign valid_o = (cnt_stripe == 1) ? ready_i : (cnt_stripe == 0) ? '0 : ready_i ; // установка сигнала для корректной работы с латентонстью

endmodule
