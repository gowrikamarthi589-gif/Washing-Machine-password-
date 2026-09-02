`timescale 1ns/1ps

module washing_machine_controller (
    input  logic clk,
    input  logic reset,
    input  logic start,

    input  logic [15:0] password,
    input  logic password_valid,

    output logic water_valve,
    output logic wash_motor,
    output logic drain_pump,
    output logic spin_motor,
    output logic done,
    output logic alarm,

    output logic [4:0] minute
);

    // =====================================================
    // PASSWORD
    // =====================================================

    localparam logic [15:0] CORRECT_PASSWORD = 16'h1410;


    // =====================================================
    // STATE ENCODING
    // =====================================================

    localparam logic [2:0] IDLE  = 3'b000;
    localparam logic [2:0] FILL  = 3'b001;
    localparam logic [2:0] WASH  = 3'b010;
    localparam logic [2:0] DRAIN = 3'b011;
    localparam logic [2:0] SPIN  = 3'b100;
    localparam logic [2:0] DONE  = 3'b101;

    logic [2:0] state;
    logic [2:0] next_state;


    // =====================================================
    // ALARM COUNTER
    // =====================================================

    logic [2:0] alarm_count;


    // =====================================================
    // STATE REGISTER
    // =====================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            state       <= IDLE;
            minute      <= 5'd0;
            alarm       <= 1'b0;
            alarm_count <= 3'd0;

        end

        else begin

            state <= next_state;


            // =================================================
            // MINUTE COUNTER
            // =================================================

            if ((state == IDLE) &&
                start &&
                password_valid &&
                (password == CORRECT_PASSWORD)) begin

                minute <= 5'd1;

            end

            else if (state == FILL) begin

                if (minute < 5)
                    minute <= minute + 1'b1;
                else
                    minute <= 5'd1;

            end

            else if (state == WASH) begin

                if (minute < 15)
                    minute <= minute + 1'b1;
                else
                    minute <= 5'd1;

            end

            else if (state == DRAIN) begin

                if (minute < 5)
                    minute <= minute + 1'b1;
                else
                    minute <= 5'd1;

            end

            else if (state == SPIN) begin

                if (minute < 5)
                    minute <= minute + 1'b1;
                else
                    minute <= 5'd0;

            end

            else if (state == IDLE) begin

                minute <= 5'd0;

            end

            else if (state == DONE) begin

                minute <= 5'd0;

            end


            // =================================================
            // START ALARM
            // =================================================

            if ((state == IDLE) &&
                (next_state == FILL)) begin

                alarm       <= 1'b1;
                alarm_count <= 3'd3;

            end

            // =================================================
            // END ALARM
            // =================================================

            else if ((state == SPIN) &&
                     (next_state == DONE)) begin

                alarm       <= 1'b1;
                alarm_count <= 3'd3;

            end

            // =================================================
            // ALARM TIMER
            // =================================================

            else if (alarm_count != 0) begin

                alarm_count <= alarm_count - 1'b1;

                if (alarm_count == 1)
                    alarm <= 1'b0;

            end

        end

    end


    // =====================================================
    // NEXT STATE LOGIC
    // =====================================================

    always_comb begin

        next_state = state;

        case (state)

            IDLE: begin

                if (start &&
                    password_valid &&
                    (password == CORRECT_PASSWORD))

                    next_state = FILL;

            end


            FILL: begin

                if (minute >= 5)
                    next_state = WASH;

            end


            WASH: begin

                if (minute >= 15)
                    next_state = DRAIN;

            end


            DRAIN: begin

                if (minute >= 5)
                    next_state = SPIN;

            end


            SPIN: begin

                if (minute >= 5)
                    next_state = DONE;

            end


            DONE: begin

                next_state = IDLE;

            end


            default: begin

                next_state = IDLE;

            end

        endcase

    end


    // =====================================================
    // OUTPUT LOGIC
    // =====================================================

    always_comb begin

        water_valve = 1'b0;
        wash_motor  = 1'b0;
        drain_pump  = 1'b0;
        spin_motor  = 1'b0;
        done        = 1'b0;

        case (state)

            IDLE: begin
            end

            FILL: begin
                water_valve = 1'b1;
            end

            WASH: begin
                wash_motor = 1'b1;
            end

            DRAIN: begin
                drain_pump = 1'b1;
            end

            SPIN: begin
                spin_motor = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
            end

        endcase

    end

endmodule