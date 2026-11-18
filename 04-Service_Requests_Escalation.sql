
DECLARE @RowsAffected INT;
DECLARE @UpdatedTickets TABLE
(
    TicketID INT,
    PreviousStatus VARCHAR(20),
    NewStatus VARCHAR(20)
);

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE dbo.SQLChallenge04_ServiceTickets
    SET
        Status = 'Escalated',
        LastUpdated = '2026-11-16 18:00:00'

    OUTPUT
        deleted.TicketID,
        deleted.Status,
        inserted.Status

    INTO @UpdatedTickets
    (
        TicketID,
        PreviousStatus,
        NewStatus
    )

    WHERE
        DueDate < '2026-11-16'
        AND Status = 'Open'
        AND Priority IN ('High', 'Critical');

    SET @RowsAffected = @@ROWCOUNT;

    IF @RowsAffected = 2
    BEGIN

        COMMIT TRANSACTION;

        SELECT
            TicketID,
            PreviousStatus,
            NewStatus
        FROM @UpdatedTickets;

        PRINT 'Transaction committed successfully.';

    END
    ELSE
    BEGIN

        ROLLBACK TRANSACTION;

        PRINT 'Transaction rolled back. Unexpected row count.';

    END;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

END CATCH;



