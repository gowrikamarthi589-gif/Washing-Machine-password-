`timescale 1ns/1ps

module washing_machine_tb;

    // =====================================================
    // INPUTS
    // =====================================================

    logic clk;
    logic reset;
    logic start;

    logic [15:0] password;
    logic password_valid;


    // =====================================================
    // OUTPUTS
    // =====================================================

    logic water_valve;
    logic wash_motor;
    logic drain_pump;
    logic spin_motor;
    logic done;
    logic alarm;

    logic [4:0] minute;


    // =====================================================
    // DUT
    // =====================================================

    washing_machine_controller uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .password(password),
        .password_valid(password_valid),
        .water_valve(water_valve),
        .wash_motor(wash_motor),
        .drain_pump(drain_pump),
        .spin_motor(spin_motor),
        .done(done),
        .alarm(alarm),
        .minute(minute)
    );


    // =====================================================
    // CLOCK
    // =====================================================

    initial begin
        clk = 1'b0;

        forever begin
            #5;
            clk = ~clk;
        end
    end


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        // -------------------------------------------------
        // RESET
        // -------------------------------------------------

        reset          = 1'b1;
        start          = 1'b0;
        password       = 16'h0000;
        password_valid = 1'b0;

        #20;

        reset = 1'b0;

        #10;


        // =================================================
        // WRONG PASSWORD TEST
        // =================================================

        $display("==========================================");
        $display("WRONG PASSWORD TEST");
        $display("==========================================");

        password       = 16'h1234;
        password_valid = 1'b1;
        start          = 1'b1;

        @(posedge clk);
        #1;

        start          = 1'b0;
        password_valid = 1'b0;
        password       = 16'h0000;

        if (uut.state == 3'b000)
            $display("PASS: Wrong password rejected.");
        else
            $display("FAIL: Wrong password accepted.");

        #10;


        // =================================================
        // CORRECT PASSWORD
        // =================================================

        $display("==========================================");
        $display("CORRECT PASSWORD TEST");
        $display("PASSWORD = 16'h1410");
        $display("==========================================");

        password       = 16'h1410;
        password_valid = 1'b1;
        start          = 1'b1;

        @(posedge clk);
        #1;

        start          = 1'b0;
        password_valid = 1'b0;


        // Check FILL
        if (uut.state == 3'b001)
            $display("PASS: IDLE -> FILL");
        else
            $display("FAIL: IDLE -> FILL");


        // Check alarm
        if (alarm == 1'b1)
            $display("PASS: Start alarm ON.");
        else
            $display("FAIL: Start alarm OFF.");


        // =================================================
        // FILL
        // =================================================

        $display("==========================================");
        $display("FILL STATE");
        $display("==========================================");

        if (water_valve == 1'b1)
            $display("PASS: Water valve ON.");
        else
            $display("FAIL: Water valve OFF.");

        repeat (5)
            @(posedge clk);

        #1;

        if (uut.state == 3'b010)
            $display("PASS: FILL -> WASH");
        else
            $display("FAIL: FILL -> WASH");


        // =================================================
        // WASH
        // =================================================

        $display("==========================================");
        $display("WASH STATE");
        $display("==========================================");

        if (wash_motor == 1'b1)
            $display("PASS: Wash motor ON.");
        else
            $display("FAIL: Wash motor OFF.");

        repeat (15)
            @(posedge clk);

        #1;

        if (uut.state == 3'b011)
            $display("PASS: WASH -> DRAIN");
        else
            $display("FAIL: WASH -> DRAIN");


        // =================================================
        // DRAIN
        // =================================================

        $display("==========================================");
        $display("DRAIN STATE");
        $display("==========================================");

        if (drain_pump == 1'b1)
            $display("PASS: Drain pump ON.");
        else
            $display("FAIL: Drain pump OFF.");

        repeat (5)
            @(posedge clk);

        #1;

        if (uut.state == 3'b100)
            $display("PASS: DRAIN -> SPIN");
        else
            $display("FAIL: DRAIN -> SPIN");


        // =================================================
        // SPIN
        // =================================================

        $display("==========================================");
        $display("SPIN STATE");
        $display("==========================================");

        if (spin_motor == 1'b1)
            $display("PASS: Spin motor ON.");
        else
            $display("FAIL: Spin motor OFF.");

        repeat (5)
            @(posedge clk);

        #1;

        if (uut.state == 3'b101)
            $display("PASS: SPIN -> DONE");
        else
            $display("FAIL: SPIN -> DONE");


        // =================================================
        // DONE
        // =================================================

        $display("==========================================");
        $display("DONE STATE");
        $display("==========================================");

        if (done == 1'b1)
            $display("PASS: DONE = 1.");
        else
            $display("FAIL: DONE = 0.");

        if (alarm == 1'b1)
            $display("PASS: End alarm ON.");
        else
            $display("FAIL: End alarm OFF.");


        // =================================================
        // DONE -> IDLE
        // =================================================

        @(posedge clk);
        #1;

        if (uut.state == 3'b000)
            $display("PASS: DONE -> IDLE");
        else
            $display("FAIL: DONE -> IDLE");


        // =================================================
        // COMPLETE
        // =================================================

        $display("==========================================");
        $display("WASHING MACHINE TEST COMPLETED");
        $display("==========================================");

        #20;

        $finish;

    end

endmodule