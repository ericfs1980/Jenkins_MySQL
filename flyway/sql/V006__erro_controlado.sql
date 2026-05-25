SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'users' 
      AND COLUMN_NAME = 'email'
      AND TABLE_SCHEMA = DATABASE()
);

SET @sql = IF(
    @col_exists = 0,
    'ALTER TABLE users ADD COLUMN email VARCHAR(255);',
    'SELECT "Column already exists";'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
