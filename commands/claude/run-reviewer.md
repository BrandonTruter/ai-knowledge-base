Execute comprehensive code evaluation using the tri-modal review framework specified below. Analyze code changes through three distinct pathways while maintaining consistent quality standards and delivering actionable feedback across all review contexts.

CORE REVIEW AGENT ARCHITECTURE

Implement automated code analysis system operating in three specialized modes with unified quality assessment protocols. Process code changes using static analysis, security scanning, and compliance validation while generating
standardized review outputs compatible with development workflows.

Target platforms: GitHub Enterprise, GitLab, Bitbucket, Azure DevOps, and local Git repositories using standard diff formats and API integrations.

MODE 1: LOCAL DIFFERENTIAL ANALYSIS ENGINE

Execute staged change evaluation within active development branch using Git working directory as source context.

PROCESSING SPECIFICATIONS
- Scan all staged files using git diff --cached command with unified diff format output
- Include binary file detection and exclude files exceeding 10MB size limit
- Process maximum 500 files per review session with 50,000 lines cumulative limit
- Generate diff analysis within 30 seconds for repositories under 1GB total size
- Support UTF-8, UTF-16, and ASCII encoding with automatic detection

INPUT REQUIREMENTS
- Active Git repository with initialized .git directory structure
- Staged changes accessible via git status --porcelain command
- Read access to repository configuration and branch history
- Working directory permissions for temporary file creation during analysis

VALIDATION CRITERIA
- Verify repository state consistency before analysis initiation
- Confirm staged changes exist using git diff-index --cached HEAD command
- Validate file accessibility and encoding compatibility for all staged files
- Check Git LFS status for large file handling requirements

MODE 2: REMOTE PULL REQUEST EVALUATION SYSTEM

Analyze GitHub pull request changes using API integration with comprehensive change context evaluation.

PROCESSING SPECIFICATIONS
- Accept GitHub pull request URLs matching pattern https://github.com/owner/repo/pull/number
- Process pull request numbers as integer values between 1 and 999999
- Retrieve diff data using GitHub REST API v4 with authentication token validation
- Handle pull requests containing maximum 300 files and 100,000 line changes
- Support cross-fork pull requests with security permission verification

INPUT REQUIREMENTS
- Valid GitHub personal access token with repository read permissions
- Pull request in open, closed, or merged state with accessible diff data
- Base and head branch availability with commit history preservation
- Network connectivity for GitHub API endpoint access at api.github.com

AUTHENTICATION SPECIFICATIONS
- Require GitHub token with repo scope for private repository access
- Support public repository analysis without authentication credentials
- Implement rate limiting compliance with GitHub API restrictions of 5000 requests per hour
- Include retry mechanism for transient network failures with exponential backoff

VALIDATION CRITERIA
- Verify pull request existence and accessibility before diff retrieval
- Confirm API token permissions align with repository visibility settings
- Validate diff completeness using GitHub API pagination for large change sets
- Check merge conflict status and base branch currency within 7 days

MODE 3: TARGETED FILE ANALYSIS FRAMEWORK

Evaluate specified files and directories using direct filesystem access with comprehensive change detection.

PROCESSING SPECIFICATIONS
- Accept file paths as absolute or relative references within repository boundary
- Process individual files up to 5MB size limit per file with encoding validation
- Support directory traversal with configurable depth limits up to 10 subdirectory levels
- Include glob pattern matching for batch file selection using standard wildcard syntax
- Generate change analysis using file modification timestamps and content hashing

INPUT REQUIREMENTS
- Valid filesystem paths accessible with current user permissions
- File references within repository root directory or specified subdirectories
- Read permissions for all target files and containing directories
- Sufficient disk space for temporary analysis artifacts up to 100MB total

VALIDATION CRITERIA
- Verify file existence and readability before content analysis initiation
- Confirm directory permissions allow recursive traversal when processing folders
- Validate file types against supported language detection using file extensions
- Check symbolic link resolution and prevent circular reference processing

REVIEW QUALITY ASSESSMENT PROTOCOL

Apply standardized evaluation metrics across all review modes using consistent scoring methodology.

ANALYSIS DIMENSIONS
- Code quality assessment using cyclomatic complexity measurement with threshold of 10 per function
- Security vulnerability detection using OWASP Top 10 classification system
- Performance impact evaluation with execution time and memory usage estimation
- Maintainability scoring based on code duplication percentage below 5% threshold
- Documentation completeness verification requiring 80% function and class coverage
- Test coverage analysis targeting minimum 85% line coverage for modified code

SCORING METHODOLOGY
- Generate numerical scores from 1-100 for each assessment dimension
- Calculate weighted composite score using security 30%, quality 25%, performance 20%, maintainability 15%, documentation 10% distribution
- Apply pass/fail thresholds with minimum 70 composite score for approval recommendation
- Include confidence intervals for automated assessments based on code complexity

OUTPUT STANDARDIZATION
- Generate structured JSON reports with consistent schema across all review modes
- Include severity classifications using CRITICAL, HIGH, MEDIUM, LOW priority levels
- Provide actionable remediation suggestions with specific line references and correction examples
- Format outputs compatible with GitHub checks API, GitLab merge request widgets, and CI/CD pipeline integration

TECHNICAL CONSTRAINT SPECIFICATIONS

SYSTEM REQUIREMENTS
- Minimum 4GB RAM allocation for review processing with 8GB recommended for large repositories
- Network bandwidth minimum 1Mbps for API operations with 10Mbps optimal for large pull requests
- Disk space requirement of 2GB for temporary analysis artifacts and caching
- Operating system compatibility with Linux, macOS, and Windows 10+ versions

SECURITY CONSTRAINTS
- Implement secure credential storage using system keychain or environment variable encryption
- Apply network request verification using TLS 1.2 minimum with certificate validation
- Ensure temporary file cleanup within 1 hour of analysis completion
- Include audit logging for all repository access and API interactions with 90-day retention

PERFORMANCE LIMITATIONS
- Process repositories up to 10GB total size with degraded performance beyond this threshold
- Support concurrent review operations limited to 5 simultaneous sessions per system
- Apply timeout limits of 300 seconds for individual file analysis and 1800 seconds for full reviews
- Include memory usage monitoring with automatic termination at 8GB consumption threshold

IMPLEMENTATION METHODOLOGY

INITIALIZATION SEQUENCE
1. Validate system prerequisites including Git installation version 2.20 minimum and required permissions
2. Authenticate API credentials and verify repository access permissions for specified review targets
3. Configure analysis parameters including file type filters, quality thresholds, and output formatting preferences
4. Initialize temporary workspace with appropriate security permissions and cleanup scheduling

EXECUTION WORKFLOW
1. Determine review mode based on input parameters with automatic detection for ambiguous inputs
2. Retrieve code changes using appropriate method with error handling and retry mechanisms
3. Parse diff content and extract modified code sections with context line preservation
4. Apply analysis rules sequentially with progress tracking and intermediate result validation
5. Generate findings report with severity classification and remediation recommendations
6. Format output according to specified delivery method with schema validation

QUALITY ASSURANCE PROCEDURES
- Implement checksum validation for all retrieved code content to ensure integrity
- Apply duplicate detection to prevent redundant analysis of identical code sections
- Include false positive filtering using machine learning models trained on repository-specific patterns
- Verify output completeness using analysis coverage metrics with 95% minimum threshold

ERROR HANDLING PROTOCOLS
- Log all errors with sufficient context for debugging including stack traces and environment details
- Implement graceful degradation for partial failures allowing completion of successful analysis components
- Provide clear error messages with actionable resolution steps for common failure scenarios
- Include retry mechanisms for transient failures with configurable attempt limits up to 3 iterations
